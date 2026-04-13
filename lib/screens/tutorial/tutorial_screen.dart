import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/api_models.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              const Color(0xFF2A1E5C),
              const Color(0xFF4B3A91)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 6,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    if (index == 5) {
                      return TutorialProfilePage(
                        onComplete: widget.onComplete,
                      );
                    }
                    return TutorialPageView(
                      pageData: localizations.getTutorialPageData(index),
                      isLastPage: false,
                      onNext: () {
                        HapticFeedback.lightImpact();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      onGetStarted: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialProfilePage extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialProfilePage({super.key, required this.onComplete});

  @override
  State<TutorialProfilePage> createState() => _TutorialProfilePageState();
}

class _TutorialProfilePageState extends State<TutorialProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  bool _participate = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isLoading = true;
  String? _currentUsername;
  SessionType _sessionType = SessionType.guest;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadSessionAndUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
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
          _nameController.text = session.username!;
        });
        await prefs.setBool(
            'userParticipateInRating', session.participateInRating);
        setState(() {
          _participate = session.participateInRating;
        });
      } else {
        // Новый пользователь – имени нет, оставляем флаг участия по умолчанию (true)
        await prefs.remove('userName');
        setState(() {
          _currentUsername = null;
          _nameController.text = '';
        });
        // Не перезаписываем _participate, оставляем текущее значение (true)
        // Но сохраняем его в prefs, чтобы синхронизировать
        await prefs.setBool('userParticipateInRating', _participate);
      }
    } catch (e) {
      print('Ошибка загрузки профиля с сервера: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSaving = true);
    final success = await AuthService().signInWithGoogle();
    if (success && mounted) {
      await _loadSessionAndUserData();
      // Если после входа имя уже есть, сразу завершаем туториал
      if (_currentUsername != null && _currentUsername!.isNotEmpty) {
        widget.onComplete();
      }
      // Если имени нет – остаёмся на экране, покажем форму ввода
    }
    setState(() => _isSaving = false);
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final trimmed = _nameController.text.trim();

    if (!_participate && trimmed.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userParticipateInRating', false);
      widget.onComplete();
      return;
    }

    if (_participate) {
      if (trimmed.isEmpty) {
        setState(() => _errorMessage = loc.translate('error_username_empty'));
        return;
      }
      if (trimmed.contains(' ')) {
        setState(() =>
            _errorMessage = loc.translate('error_username_contains_space'));
        return;
      }
      if (trimmed.length < 3) {
        setState(
            () => _errorMessage = loc.translate('error_username_too_short'));
        return;
      }
      if (trimmed.length > 20) {
        setState(
            () => _errorMessage = loc.translate('error_username_too_long'));
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

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
        if (_participate) {
          await UserAPIService().updateMyProfile(
            token: token,
            username: trimmed,
            participateInRating: true,
          );
        } else {
          await UserAPIService().updateMyRating(
            token: token,
            participateInRating: false,
          );
        }

        final prefs = await SharedPreferences.getInstance();
        if (_participate && trimmed.isNotEmpty) {
          await prefs.setString('userName', trimmed);
        }
        await prefs.setBool('userParticipateInRating', _participate);

        widget.onComplete();
        return true;
      } catch (e) {
        print('❌ Ошибка сохранения профиля: $e');
        if (e is UserAPIError) {
          if (e == UserAPIError.invalidToken ||
              e == UserAPIError.unauthorized) {
            return false;
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

    bool success = await performSave();
    if (success) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      final auth = await UserAPIService().anonymousAuth();
      await SessionManager().setAccessToken(auth.accessToken);
      await SessionManager().setUserId(auth.userId);
      print('🔄 Токен обновлён, повторяем запрос...');
      await performSave();
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось обновить токен. Попробуйте позже.';
        _isSaving = false;
      });
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Случай 1: гость – только кнопки Google и Пропустить
    if (_sessionType == SessionType.guest) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  loc.getTutorialProfileImageAsset(),
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('tutorial_title_profile'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('tutorial_desc_profile'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Кнопка Google
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _signInWithGoogle,
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: Text(loc.translate('google_sign_in_button'),
                            style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Кнопка "Пропустить"
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _skip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          loc.translate('skip_button') ?? 'Skip',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Случай 2: авторизован, но нет имени – показываем форму
    if (_currentUsername == null || _currentUsername!.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  loc.getTutorialProfileImageAsset(),
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('tutorial_title_profile'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('tutorial_desc_profile'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Поле имени
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('user_name_label'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            enabled: !_isSaving,
                          ),
                          onChanged: (v) {
                            if (v.length > 20)
                              _nameController.text = v.substring(0, 20);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Переключатель участия
                    SwitchListTile(
                      title: Text(
                        loc.translate('user_ranking_toggle'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      value: _participate,
                      onChanged: _isSaving
                          ? null
                          : (val) => setState(() => _participate = val),
                      activeColor: const Color(0xFF8B5CF6),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    // Ошибка под полем
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    // Кнопка "Начать страдать"
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(loc.tutorialStartSufferingButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Случай 3: авторизован и имя есть – сразу кнопка "Начать страдать"
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                loc.getTutorialProfileImageAsset(),
                                width: 300,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('tutorial_title_profile'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('tutorial_desc_profile'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Приветствие
                  Text(
                    '${loc.translate('welcome_back') ?? 'Welcome back'}, $_currentUsername!',
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFFC7FF00)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(loc.tutorialStartSufferingButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TutorialPageView extends StatefulWidget {
  final TutorialPageData pageData;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const TutorialPageView({
    super.key,
    required this.pageData,
    required this.isLastPage,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  State<TutorialPageView> createState() => _TutorialPageViewState();
}

class _TutorialPageViewState extends State<TutorialPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Картинка
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                widget.pageData.imageAsset,
                                width: 300,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Текст
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                widget.pageData.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.pageData.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        // Кнопка всегда внизу
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildButton(),
        ),
      ],
    );
  }

  Widget _buildButton() {
    final localizations = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: widget.onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.15),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.tutorialNextButton,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 14),
        ],
      ),
    );
  }
}
