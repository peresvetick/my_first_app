import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_first_app/app/main_navigation.dart';
import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/data/app_store.dart';

/// Красивый экран входа NatureHub.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final login = _loginCtrl.text.trim();
    final password = _passCtrl.text.trim();

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final ok = (login == 'albert' && password == '1000') || (login == 'ivan' && password == '1111');
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Неверный логин или пароль'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    await AppStore().updateProfile(login, AppStore().userAvatar);
    if (!mounted) return;
    Navigator.pushReplacement(context, natureRoute(const MainNavigationScreen()));
  }

  void _quickFill(String login, String pass) {
    setState(() {
      _loginCtrl.text = login;
      _passCtrl.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          // Фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F3D2E), Color(0xFF1B5E3B), Color(0xFF2E7D4F)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.12),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.forest, size: 56, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'NatureHub',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Карты, маршруты и сообщество природы',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Вход',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Добро пожаловать обратно',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _loginCtrl,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите логин' : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Логин',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
                                  decoration: InputDecoration(
                                    labelText: 'Пароль',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _handleLogin,
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Text('Войти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text('Быстрый вход (демо)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ActionChip(
                                      avatar: const Text('🌲'),
                                      label: const Text('albert'),
                                      onPressed: () => _quickFill('albert', '1000'),
                                    ),
                                    ActionChip(
                                      avatar: const Text('🧭'),
                                      label: const Text('ivan'),
                                      onPressed: () => _quickFill('ivan', '1111'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Продолжая, вы соглашаетесь беречь природу 🌿',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
