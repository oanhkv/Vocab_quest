import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Hệ thống màu sắc - Gradient hiện đại, thu hút giới trẻ
class AppColors {
  // Màu chính - Tím xanh hiện đại
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4A44CC);
  static const primaryLight = Color(0xFF9D97FF);

  // Màu phụ - Hồng cam
  static const secondary = Color(0xFFFF6584);
  static const accent = Color(0xFFFFD93D);

  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFFF5252);
  static const info = Color(0xFF2196F3);

  // Backgrounds
  static const background = Color(0xFFF5F7FB);
  static const backgroundDark = Color(0xFF1A1A2E);
  static const cardBg = Colors.white;
  static const cardBgDark = Color(0xFF2A2A3E);

  // Text
  static const textPrimary = Color(0xFF2D2D3F);
  static const textSecondary = Color(0xFF6E6E80);
  static const textLight = Color(0xFFAAAABC);

  // Gradient cho các game khác nhau
  static const gradientPurple = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const gradientPink = [Color(0xFFF093FB), Color(0xFFF5576C)];
  static const gradientBlue = [Color(0xFF4FACFE), Color(0xFF00F2FE)];
  static const gradientOrange = [Color(0xFFFA709A), Color(0xFFFEE140)];
  static const gradientGreen = [Color(0xFF43E97B), Color(0xFF38F9D7)];
  static const gradientRed = [Color(0xFFFF6A88), Color(0xFFFF99AC)];
  static const gradientGold = [Color(0xFFFFD700), Color(0xFFFFA500)];
  static const gradientDark = [Color(0xFF232526), Color(0xFF414345)];

  // Level colors
  static const beginnerColor = Color(0xFF4CAF50);      // Xanh lá
  static const intermediateColor = Color(0xFFFF9800);  // Cam
  static const advancedColor = Color(0xFFE91E63);      // Hồng đậm
}

/// 📏 Khoảng cách và kích thước chuẩn
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double padding = 16.0;
  static const double paddingLarge = 24.0;

  static const double radiusSmall = 8.0;
  static const double radius = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusCircle = 100.0;

  static const double iconSmall = 16.0;
  static const double icon = 24.0;
  static const double iconLarge = 36.0;
  static const double iconXLarge = 48.0;
}

/// 🌈 Theme tổng thể của app
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    // ⭐ FIX: Flutter 3.27+ đổi tên CardTheme → CardThemeData
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    // ⭐ FIX: CardTheme → CardThemeData
    cardTheme: CardThemeData(
      color: AppColors.cardBgDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      backgroundColor: AppColors.cardBgDark,
      elevation: 8,
    ),
  );
}