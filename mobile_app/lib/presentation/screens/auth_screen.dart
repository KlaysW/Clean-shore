import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/auth/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<AuthBloc>();
    if (_isRegisterMode) {
      bloc.add(AuthRegisterRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
      ));
    } else {
      bloc.add(AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/wave.svg',
                      height: 80,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryGreenEnd,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Чистый берег', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Экологический мониторинг и квесты',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 32),

                    if (_isRegisterMode) ...[
                      TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(hintText: 'Никнейм'),
                        validator: (v) =>
                            (v == null || v.trim().length < 2) ? 'Введите никнейм' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Введите корректный email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Пароль'),
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'Минимум 8 символов' : null,
                    ),
                    const SizedBox(height: 24),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isRegisterMode
                                      ? 'Создать аккаунт'
                                      : 'Начать спасать планету',
                                  style: AppTextStyles.buttonLabel,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                      child: Text(
                        _isRegisterMode
                            ? 'Уже есть аккаунт? Войти'
                            : 'Нет аккаунта? Зарегистрироваться',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('или'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _SsoButton(label: 'Яндекс', onTap: () {}),
                    const SizedBox(height: 12),
                    _SsoButton(label: 'Google', onTap: () {}),
                    const SizedBox(height: 12),
                    _SsoButton(label: 'VK', onTap: () {}),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  const _SsoButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: AppTextStyles.bodyRegular),
    );
  }
}