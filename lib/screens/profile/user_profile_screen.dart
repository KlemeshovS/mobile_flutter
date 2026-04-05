import 'package:flutter/material.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _participate = prefs.getBool('userParticipateInRating') ?? true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    widget.onDisappear?.call();
    super.dispose();
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final trimmed = _nameController.text.trim();

    if (!_participate && trimmed.isEmpty) {
      // просто сохраняем локально, ничего не отправляем
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userParticipateInRating', false);
      // закрыть экран или вызвать onSaveSuccess
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

    // Функция для выполнения запроса с текущим токеном
    Future<bool> performSave() async {
      final token = SessionManager().accessToken;
      if (token == null) {
        setState(() {
          _errorMessage = loc.translate('error_missing_token');
          _isSaving = false;
        });
        return false;
      }

      try {
        late MeResponse profile;
        if (_participate) {
          // Включаем участие – отправляем имя
          profile = await UserAPIService().updateMyProfile(
            token: token,
            username: trimmed,
            participateInRating: true,
          );
        } else {
          // Выключаем участие – не трогаем имя
          profile = await UserAPIService().updateMyRating(
            token: token,
            participateInRating: false,
          );
        }

        final prefs = await SharedPreferences.getInstance();
        if (_participate && trimmed.isNotEmpty) {
          await prefs.setString('userName', trimmed);
        }
        // Сохраняем флаг участия в любом случае
        await prefs.setBool('userParticipateInRating', _participate);

        widget.onRegisterSuccess?.call(trimmed, profile.id, _participate);

        if (mounted) {
          Navigator.pop(context);
        }
        return true;
      } catch (e) {
        print('❌ Ошибка сохранения профиля: $e');
        if (e is UserAPIError) {
          if (e == UserAPIError.invalidAuthToken || e == UserAPIError.unauthorized) {
            return false; // сигнал для повторной попытки с новым токеном
          } else {
            String msg;
            if (e == UserAPIError.usernameAlreadyExists) {
              msg = loc.translate('error_username_already_exists');
            } else if (e == UserAPIError.usernameTooShort) {
              msg = loc.translate('error_username_too_short');
            } else if (e == UserAPIError.usernameTooLong) {
              msg = loc.translate('error_username_too_long');
            } else if (e == UserAPIError.usernameInvalidCharacters) {
              msg = loc.translate('error_username_invalid_characters');
            } else if (e == UserAPIError.validationError) {
              msg = loc.translate('error_username_invalid_characters');
            } else {
              msg = e.toString();
            }
            setState(() {
              _errorMessage = msg;
              _isSaving = false;
            });
            return true;
          }
        } else {
          setState(() {
            _errorMessage = e.toString();
            _isSaving = false;
          });
          return true;
        }
      }
    }

    // Первая попытка
    bool success = await performSave();
    if (success) return;

    // Если ошибка токена, пробуем обновить токен и повторить
    setState(() {
      _errorMessage = null;
    });

    try {
      final auth = await UserAPIService().anonymousAuth();
      await SessionManager().setAccessToken(auth.accessToken);
      await SessionManager().setUserId(auth.userId);
      print('🔄 Токен обновлён, повторяем запрос...');
      await performSave(); // performSave сам обработает результат и закроет экран при успехе
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось обновить токен. Попробуйте позже.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                      icon: Icon(Icons.close, color: Colors.white70),
                      onPressed: widget.onClose,
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF8B5CF6).withOpacity(0.3),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        SizedBox(height: 24),
                        Text(
                          loc.translate('tutorial_title_profile'),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        // Подзаголовок
                        Text(
                          loc.translate('tutorial_desc_profile'),
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),

                        // Поле ввода с лейблом сверху
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Лейбл поля имени
                            Text(
                              loc.translate('user_name_label'),
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabled: !_isSaving,
                              ),
                              onChanged: (v) {
                                if (v.length > 20) _nameController.text = v.substring(0, 20);
                              },
                            ),
                          ],
                        ),

                        // Фиксированное место для ошибки
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 8),
                          child: _errorMessage != null
                              ? Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          )
                              : null,
                        ),

                        SwitchListTile(
                          title: Text(
                            loc.translate('user_ranking_toggle'),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: _participate,
                          onChanged: _isSaving ? null : (val) => setState(() => _participate = val),
                          activeColor: Color(0xFF8B5CF6),
                          contentPadding: EdgeInsets.zero,
                        ),

                        SizedBox(height: 24),

                        // Кнопка Сохранить
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              loc.translate('save_button'),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
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