import 'package:flutter/material.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/auth_service.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/api_models.dart';

class UserProfileScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(String, int, bool)? onRegisterSuccess;
  final VoidCallback? onDisappear;

  const UserProfileScreen({
    super.key,
    this.onClose,
    this.onRegisterSuccess,
    this.onDisappear,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _participate = true;
  bool _isSaving = false;
  String? _errorMessage;

  SessionType _sessionType = SessionType.guest;
  bool _isLoading = true;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadSessionAndUserData();
  }

  Future<void> _loadSessionAndUserData() async {
    setState(() => _isLoading = true);
    await SessionManager().init();
    final session = SessionManager();
    setState(() {
      _sessionType = session.sessionType;
    });

    if (_sessionType == SessionType.authenticated) {
      await _loadUserData();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    final participate = prefs.getBool('userParticipateInRating') ?? true;
    setState(() {
      _currentUsername = name;
      _participate = participate;
      _nameController.text = name ?? '';
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final success = await AuthService().signInWithGoogle();
    if (success && mounted) {
      await _loadSessionAndUserData();
      // Уведомляем родителя, чтобы обновить рейтинги и т.д.
      widget.onRegisterSuccess?.call(_nameController.text.trim(), SessionManager().userId ?? 0, _participate);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось войти через Google')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await AuthService().signOut();
    if (mounted) {
      await _loadSessionAndUserData();
      widget.onRegisterSuccess?.call('', 0, false);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final trimmed = _nameController.text.trim();

    if (!_participate && trimmed.isEmpty) {
      // Отключаем участие, имя не нужно
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userParticipateInRating', false);
      if (mounted) Navigator.pop(context);
      return;
    }

    if (_participate) {
      if (trimmed.isEmpty) {
        setState(() => _errorMessage = loc.translate('error_username_empty'));
        return;
      }
      if (trimmed.contains(' ')) {
        setState(() => _errorMessage = loc.translate('error_username_contains_space'));
        return;
      }
      if (trimmed.length < 3) {
        setState(() => _errorMessage = loc.translate('error_username_too_short'));
        return;
      }
      if (trimmed.length > 20) {
        setState(() => _errorMessage = loc.translate('error_username_too_long'));
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final token = SessionManager().accessToken;
    if (token == null) {
      setState(() {
        _errorMessage = loc.translate('error_missing_token');
        _isSaving = false;
      });
      return;
    }

    try {
      if (_participate) {
        // Включаем участие – отправляем имя
        await UserAPIService().updateMyProfile(
          token: token,
          username: trimmed,
          participateInRating: true,
        );
      } else {
        // Выключаем участие – отправляем только флаг
        await UserAPIService().updateMyRating(
          token: token,
          participateInRating: false,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      if (_participate && trimmed.isNotEmpty) {
        await prefs.setString('userName', trimmed);
        setState(() => _currentUsername = trimmed);
      }
      await prefs.setBool('userParticipateInRating', _participate);

      widget.onRegisterSuccess?.call(trimmed, SessionManager().userId ?? 0, _participate);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Ошибка сохранения профиля: $e');
      String msg;
      if (e is UserAPIError) {
        switch (e) {
          case UserAPIError.usernameAlreadyExists:
            msg = loc.translate('error_username_already_exists');
            break;
          case UserAPIError.usernameTooShort:
            msg = loc.translate('error_username_too_short');
            break;
          case UserAPIError.usernameTooLong:
            msg = loc.translate('error_username_too_long');
            break;
          case UserAPIError.usernameInvalidCharacters:
            msg = loc.translate('error_username_invalid_characters');
            break;
          default:
            msg = e.toString();
        }
      } else {
        msg = e.toString();
      }
      setState(() {
        _errorMessage = msg;
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.onDisappear?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2E).withOpacity(0.98), Color(0xFF2A2A3A).withOpacity(0.98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Гостевой режим – показываем кнопку входа
    if (_sessionType == SessionType.guest) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2E).withOpacity(0.98), Color(0xFF2A2A3A).withOpacity(0.98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (widget.onClose != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: widget.onClose,
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF8B5CF6),
                            child: Icon(Icons.person_outline, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            loc.translate('profile_guest_title'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('profile_guest_message'),
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _signInWithGoogle,
                              icon: const Icon(Icons.login, color: Colors.white),
                              label: const Text('Войти через Google', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Авторизованный режим – форма профиля
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E).withOpacity(0.98), Color(0xFF2A2A3A).withOpacity(0.98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onClose != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: widget.onClose,
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                          child: const Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.translate('tutorial_title_profile'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('tutorial_desc_profile'),
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Поле имени
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('user_name_label'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabled: !_isSaving,
                              ),
                              onChanged: (v) {
                                if (v.length > 20) _nameController.text = v.substring(0, 20);
                              },
                            ),
                          ],
                        ),

                        // Ошибка
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 8),
                          child: _errorMessage != null
                              ? Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14))
                              : null,
                        ),

                        // Переключатель участия
                        SwitchListTile(
                          title: Text(
                            loc.translate('user_ranking_toggle'),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: _participate,
                          onChanged: _isSaving ? null : (val) => setState(() => _participate = val),
                          activeColor: const Color(0xFF8B5CF6),
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 24),

                        // Кнопка сохранить
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              loc.translate('save_button'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Кнопка выхода
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Выйти', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}