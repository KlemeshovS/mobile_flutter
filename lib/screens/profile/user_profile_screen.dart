import 'package:flutter/material.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/auth_service.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/utils/achievement_manager.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wobbly/models/follow_models.dart';

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
  bool _participate = true;
  bool _isLoading = true;
  String? _errorMessage;

  File? _avatarFile;          // локальный файл, если выбрали/обрезали
  String? _avatarUrl;         // URL с сервера
  bool _isUploadingAvatar = false;

  List<FollowModel> _myFollows = [];
  List<FollowModel> _myFollowers = [];
  bool _isLoadingFollows = false;

  int _unlockedAchievements = 0;
  int _totalAchievements = 0;

  SessionType _sessionType = SessionType.guest;
  String? _currentUsername;
  // Для редактирования имени (если нет имени)
  final TextEditingController _tempNameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadSessionAndUserData();
    _loadAchievementsCount();
    if (SessionManager().sessionType == SessionType.authenticated) {
      _loadFollowData();
    }
  }

  Future<void> _loadAchievementsCount() async {
    final manager = AchievementManager();
    await manager.loadAchievements();
    setState(() {
      _unlockedAchievements = manager.unlockedAchievementsCount;
      _totalAchievements = manager.totalAchievementsCount;
    });
  }

  Future<void> _loadSessionAndUserData() async {
    setState(() => _isLoading = true);
    await SessionManager().init();
    final session = SessionManager();
    setState(() {
      _sessionType = session.sessionType;
    });

    if (_sessionType == SessionType.authenticated) {
      await _loadUserDataFromServer();
    } else {
      // Сбрасываем аватар только если не авторизованы
      setState(() {
        _avatarUrl = null;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserDataFromServer() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    try {
      final session = await UserAPIService().getSession(token);
      final prefs = await SharedPreferences.getInstance();
      if (session.username != null && session.username!.isNotEmpty) {
        // Существующий пользователь – загружаем имя и настройку участия
        await prefs.setString('userName', session.username!);
        setState(() {
          _currentUsername = session.username;
        });
        await prefs.setBool('userParticipateInRating', session.participateInRating);
        setState(() {
          _participate = session.participateInRating;
        });
      } else {
        // Новый пользователь – имени нет, оставляем флаг участия по умолчанию (true)
        await prefs.remove('userName');
        setState(() {
          _currentUsername = null;
        });
        // Не перезаписываем _participate, оставляем текущее значение (true)
        await prefs.setBool('userParticipateInRating', _participate);
      }
      setState(() {
        _avatarUrl = UserAPIService.fullAvatarUrl(session.avatarUrl);
      });

    } catch (e) {
      print('Ошибка загрузки профиля с сервера: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final success = await AuthService().signInWithGoogle();
    if (success && mounted) {
      await _loadSessionAndUserData();
      widget.onRegisterSuccess?.call(_currentUsername ?? '', SessionManager().userId ?? 0, _participate);
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

  // Обновление имени через диалог
  Future<void> _editUsername() async {
    final loc = AppLocalizations.of(context);
    final TextEditingController controller = TextEditingController(text: _currentUsername ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B55),
        title: Text(
          loc.translate('edit_username_title') ?? 'Edit username',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: loc.translate('user_name_label'),
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC7FF00), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              loc.translate('cancel') ?? 'Cancel',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('save_button')),
          ),
        ],
      ),
    );
    if (result == true) {
      final newName = controller.text.trim();
      if (newName.isEmpty) {
        _showError(loc.translate('error_username_empty'));
        return;
      }
      if (newName.contains(' ')) {
        _showError(loc.translate('error_username_contains_space'));
        return;
      }
      if (newName.length < 3) {
        _showError(loc.translate('error_username_too_short'));
        return;
      }
      if (newName.length > 20) {
        _showError(loc.translate('error_username_too_long'));
        return;
      }
      await _saveUsername(newName);
    }
  }

  Future<void> _saveUsername(String newName) async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      await UserAPIService().updateMyProfile(
        token: token,
        username: newName,
        participateInRating: _participate,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);
      setState(() {
        _currentUsername = newName;
        _isEditingName = false;
      });
      widget.onRegisterSuccess?.call(newName, SessionManager().userId ?? 0, _participate);
    } catch (e) {
      String msg;
      if (e is UserAPIError) {
        switch (e) {
          case UserAPIError.usernameAlreadyExists:
            msg = AppLocalizations.of(context).translate('error_username_already_exists');
            break;
          case UserAPIError.usernameTooShort:
            msg = AppLocalizations.of(context).translate('error_username_too_short');
            break;
          case UserAPIError.usernameTooLong:
            msg = AppLocalizations.of(context).translate('error_username_too_long');
            break;
          case UserAPIError.usernameInvalidCharacters:
            msg = AppLocalizations.of(context).translate('error_username_invalid_characters');
            break;
          default:
            msg = e.toString();
        }
      } else {
        msg = e.toString();
      }
      _showError(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNewNameFromField() async {
    final newName = _tempNameController.text.trim();
    if (newName.isEmpty) {
      _showError(AppLocalizations.of(context).translate('error_username_empty'));
      return;
    }
    if (newName.contains(' ')) {
      _showError(AppLocalizations.of(context).translate('error_username_contains_space'));
      return;
    }
    if (newName.length < 3) {
      _showError(AppLocalizations.of(context).translate('error_username_too_short'));
      return;
    }
    if (newName.length > 20) {
      _showError(AppLocalizations.of(context).translate('error_username_too_long'));
      return;
    }
    await _saveUsername(newName);
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _pickAndCropAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    print('Выбрано изображение: ${pickedFile.path}');

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Обрезка',
          toolbarColor: const Color(0xFF2D2B55),
          backgroundColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Обрезка',
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedFile != null) {
      print('Изображение обрезано: ${croppedFile.path}');
      setState(() {
        _avatarFile = File(croppedFile.path);
      });
      await _uploadAvatar();
    } else {
      print('Кроп отменён или не удался');
    }
  }

  Future<void> _uploadAvatar() async {
    if (_avatarFile == null) return;
    final token = SessionManager().accessToken;
    print('Токен для загрузки аватара: ${token != null ? "есть" : "отсутствует"}');
    if (token == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      const maxSizeBytes = 2 * 1024 * 1024;
      final fileSize = await _avatarFile!.length();
      print('Размер файла: $fileSize байт');
      if (fileSize > maxSizeBytes) {
        _showError('Файл слишком большой. Максимум 2 МБ.');
        return;
      }

      print('Начинаем загрузку аватара на сервер...');
      final profile = await UserAPIService().uploadAvatar(
        token: token,
        imageFile: _avatarFile!,
      );
      print('Ответ от сервера: avatarUrl = ${profile.avatarUrl}');
      setState(() {
        _avatarUrl = UserAPIService.fullAvatarUrl(profile.avatarUrl);
        _avatarFile = null;
      });
    } catch (e) {
      print('Ошибка загрузки аватара: $e');
      String msg = 'Не удалось загрузить аватар';
      if (e is UserAPIError) {
        if (e == UserAPIError.avatarTooLarge) msg = 'Аватар слишком большой';
        else if (e == UserAPIError.avatarInvalidImage) msg = 'Неподдерживаемый формат изображения';
        else if (e == UserAPIError.invalidToken) msg = 'Сессия устарела, войдите заново';
      }
      _showError(msg);
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _deleteAvatar() async {
    final token = SessionManager().accessToken;
    if (token == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final profile = await UserAPIService().deleteAvatar(token);
      setState(() {
        _avatarUrl = UserAPIService.fullAvatarUrl(profile.avatarUrl);
        _avatarFile = null;
      });
    } catch (e) {
      _showError('Не удалось удалить аватар');
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  // Сохранение переключателя участия
  Future<void> _toggleParticipate(bool value) async {
    setState(() => _participate = value);
    final token = SessionManager().accessToken;
    if (token == null) return;
    try {
      await UserAPIService().updateMyRating(
        token: token,
        participateInRating: value,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userParticipateInRating', value);
      widget.onRegisterSuccess?.call(_currentUsername ?? '', SessionManager().userId ?? 0, value);
    } on UserAPIError catch (e) {
      if (e == UserAPIError.authRequiredForRating || e == UserAPIError.guestCannotEnableRating) {
        setState(() => _participate = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).translate('error_auth_required_for_rating')),
          ));
        }
      } else {
        setState(() => _participate = !value);
      }
    } catch (e) {
      setState(() => _participate = !value);
    }
  }

  Future<void> _loadFollowData() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isLoadingFollows = true);
    try {
      final follows = await UserAPIService().getMyFollows(token);
      final followers = await UserAPIService().getMyFollowers(token);
      setState(() {
        _myFollows = follows.items;
        _myFollowers = followers.items;
      });
    } catch (e) {
      print('❌ Ошибка загрузки подписок: $e');
    } finally {
      setState(() => _isLoadingFollows = false);
    }
  }

  List<FollowModel> get _pendingFollowers => _myFollowers
      .where((f) => !_myFollows.any((m) => m.userId == f.userId))
      .toList();

  Future<void> _unfollowUser(int userId) async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    try {
      await UserAPIService().unfollow(token, userId);
      await _loadFollowData();
    } catch (e) {
      _showError('Ошибка при отписке');
    }
  }

  Future<void> _followBack(String username) async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    try {
      await UserAPIService().follow(token, username);
      await _loadFollowData();
    } catch (e) {
      _showError('Ошибка при подписке');
    }
  }

  Widget _buildFollowsSection(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  loc.translate('your_friends_title'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_myFollows.isNotEmpty)
                  Text(
                    '${_myFollows.length}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          if (_isLoadingFollows)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else if (_myFollows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  loc.translate('friends_empty_title'),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myFollows.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1, indent: 64),
              itemBuilder: (context, index) {
                final follow = _myFollows[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildAvatar(follow.avatarUrl, 36),
                  title: Text(
                    follow.username,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: follow.isMutual
                      ? Text(
                    loc.translate('user_is_friend'),
                    style: const TextStyle(color: Color(0xFFC7FF00), fontSize: 11),
                  )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (follow.isMutual)
                        const Icon(Icons.people, color: Color(0xFFC7FF00), size: 16),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        color: const Color(0xFF1E1C3A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        elevation: 8,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.more_horiz, color: Colors.white70, size: 18),
                        ),
                        onSelected: (value) {
                          if (value == 'unfollow') _unfollowUser(follow.userId);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'unfollow',
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person_remove, color: Colors.redAccent, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  loc.translate('remove_friend_button'),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFollowersSection(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  loc.translate('followers_pending_title'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_pendingFollowers.length}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingFollowers.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1, indent: 64),
            itemBuilder: (context, index) {
              final follower = _pendingFollowers[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _buildAvatar(follower.avatarUrl, 36),
                title: Text(
                  follower.username,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                trailing: TextButton(
                  onPressed: () => _followBack(follower.username),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    loc.translate('follow_button'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, double size) {
    final fullUrl = UserAPIService.fullAvatarUrl(avatarUrl);
    if (fullUrl != null) {
      return CachedNetworkImage(
        imageUrl: fullUrl,
        httpHeaders: UserAPIService.stagingHeaders,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
        ),
        placeholder: (_, __) => _defaultAvatar(size),
        errorWidget: (_, __, ___) => _defaultAvatar(size),
      );
    }
    return _defaultAvatar(size);
  }

  Widget _defaultAvatar(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white.withOpacity(0.15),
      child: Icon(Icons.person, color: Colors.white60, size: size * 0.5),
    );
  }

  @override
  void dispose() {
    _tempNameController.dispose();
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

    // Гостевой режим
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
                          // Кнопка Google (белая)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                surfaceTintColor: Colors.transparent,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/google_logo.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    loc.translate('google_sign_in_button'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Кнопка Яндекса
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                final success = await AuthService().signInWithYandex();
                                if (success && mounted) {
                                  await _loadSessionAndUserData();
                                  widget.onRegisterSuccess?.call(
                                    _currentUsername ?? '',
                                    SessionManager().userId ?? 0,
                                    _participate,
                                  );
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context).translate('yandex_sign_in_error')),
                                      ),
                                    );
                                  }
                                }
                                setState(() => _isLoading = false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade700),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/yandex_logo.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context).translate('sign_in_with_yandex'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),                        ],
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

    // Авторизованный режим
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
                        // ===== АВАТАР (показывается всегда) =====
                        GestureDetector(
                          onTap: _pickAndCropAvatar,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _avatarFile != null
                                  ? CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(_avatarFile!),
                              )
                                  : CachedNetworkImage(
                                imageUrl: _avatarUrl ?? '',
                                httpHeaders: UserAPIService.stagingHeaders,
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 50,
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: (_avatarFile != null || _avatarUrl != null)
                                      ? _deleteAvatar
                                      : null,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      (_avatarFile != null || _avatarUrl != null)
                                          ? Icons.delete
                                          : Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isUploadingAvatar)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),

                        const SizedBox(height: 16),

                        // ===== ЗАГОЛОВОК (имя или "Профиль") =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _currentUsername?.isNotEmpty == true
                                    ? _currentUsername!
                                    : loc.translate('profile_default_title'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _currentUsername?.isNotEmpty == true
                                      ? const Color(0xFFC7FF00)
                                      : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_currentUsername?.isNotEmpty == true) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _editUsername,
                                child: const Icon(Icons.edit, color: Colors.white70, size: 20),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('profile_authenticated_subtitle'),
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // ===== ПОЛЕ ВВОДА ИМЕНИ (если нет) =====
                        if (_currentUsername == null || _currentUsername!.isEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('user_name_label'),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _tempNameController,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _saveNewNameFromField,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(loc.translate('save_button')),
                                ),
                              ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ],

                        // ===== ПЕРЕКЛЮЧАТЕЛЬ УЧАСТИЯ =====
                        SwitchListTile(
                          title: Text(
                            loc.translate('user_ranking_toggle'),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: _participate,
                          onChanged: _toggleParticipate,
                          activeColor: const Color(0xFF8B5CF6),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        // ===== ПЛАШКА ДОСТИЖЕНИЙ =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Color(0xFFC7FF00), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  loc.translate('menu_achievements_title'),
                                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                              ),
                              Text(
                                '$_unlockedAchievements/$_totalAchievements',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== МОИ ПОДПИСКИ =====
                        _buildFollowsSection(loc),
                        const SizedBox(height: 16),

                        // ===== ПОДПИСЧИКИ =====
                        if (_pendingFollowers.isNotEmpty)
                          _buildFollowersSection(loc),
                        const SizedBox(height: 24),

                      ],   // закрытие children внутреннего Column
                    ),     // закрытие Column
                  ),       // закрытие SingleChildScrollView
                ),         // закрытие Expanded
              ],           // закрытие children внешнего Column
            ),             // закрытие Column
          ),               // закрытие Padding
        ),                 // закрытие SafeArea
      ),                   // закрытие Container
    );                     // закрытие Scaffold
  }
}
