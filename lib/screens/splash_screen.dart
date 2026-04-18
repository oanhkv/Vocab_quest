import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

// Man hinh Splash - hien thi khi app khoi dong
// Kiem tra trang thai dang nhap de dieu huong toi Home hoac Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      final userProvider = context.read<UserProvider>();
      await userProvider.init();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientPurple,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cac hinh tron trang tri nen
              _buildBackgroundCircle(
                top: -50,
                right: -50,
                size: 200,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _buildBackgroundCircle(
                bottom: -80,
                left: -80,
                size: 280,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _buildBackgroundCircle(
                top: 100,
                left: -40,
                size: 120,
                color: AppColors.accent.withValues(alpha: 0.15),
              ),

              // Noi dung chinh
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),

                    const SizedBox(height: 32),

                    // Ten app
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 800.ms,
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                    const SizedBox(height: 80),

                    // Loading dots
                    _buildLoadingDots(),
                  ],
                ),
              ),

              // Phien ban app o cuoi
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Text(
                  'Phien ban ${AppConstants.appVersion}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logo voi animation xoay + phong to
  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vong tron xoay o ngoai
          AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => Transform.rotate(
              angle: _animController.value * 6.28,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 52,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Icon chinh
          const Icon(
            FontAwesomeIcons.graduationCap,
            size: 50,
            color: AppColors.primary,
          )
              .animate(
            onPlay: (ctr) => ctr.repeat(reverse: true),
          )
              .scale(
            duration: 1500.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.1, 1.1),
          ),
        ],
      ),
    ).animate().scale(
      duration: 800.ms,
      curve: Curves.elasticOut,
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
    );
  }

  // 3 dau cham nhap nhay the hien dang loading
  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              .animate(
            onPlay: (ctr) => ctr.repeat(),
            delay: (i * 200).ms,
          )
              .fadeIn(duration: 400.ms)
              .then()
              .fadeOut(duration: 400.ms),
        );
      }),
    );
  }

  // Hinh tron trang tri nen
  Widget _buildBackgroundCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}