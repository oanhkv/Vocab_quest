import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

/// 📝 Màn hình Đăng ký
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      Helpers.showError(context, 'Vui lòng đồng ý điều khoản sử dụng');
      return;
    }

    final provider = context.read<UserProvider>();
    final success = await provider.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSuccess(context, 'Đăng ký thành công! Chào mừng bạn 🎉');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Helpers.showError(context, provider.errorMessage ?? 'Đăng ký thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientPink,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.userPlus,
                        size: 60,
                        color: Colors.white,
                      ).animate().scale(
                          duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Tạo tài khoản',
                        style: AppText.display.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bắt đầu hành trình học từ vựng',
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên
                        TextFormField(
                          controller: _nameCtrl,
                          validator: Validators.displayName,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị',
                            prefixIcon: Icon(LucideIcons.user,
                                color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(LucideIcons.mail,
                                color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          validator: Validators.password,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(LucideIcons.lock,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordCtrl.text),
                          decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu',
                            prefixIcon: const Icon(LucideIcons.lock,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye),
                              onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Terms
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  setState(() => _acceptTerms = v ?? false),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                        () => _acceptTerms = !_acceptTerms),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(text: 'Tôi đồng ý với '),
                                      TextSpan(
                                        text: 'Điều khoản sử dụng',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Register button
                        Consumer<UserProvider>(
                          builder: (context, provider, _) {
                            return GradientButton(
                              text: 'Tạo tài khoản',
                              icon: LucideIcons.userPlus,
                              gradient: AppColors.gradientPink,
                              isLoading: provider.isLoading,
                              onPressed: _register,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Login link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản? ',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Đăng nhập',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
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
}