import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'config/theme.dart';
import 'providers/user_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/game_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/games/game_menu_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/favorites/favorites_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Firebase init with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo dịch vụ âm thanh (đọc settings + phát nhạc nền nếu bật).
  // Bọc try/catch để lỗi audio không chặn app khởi động.
  try {
    await AudioService.instance.init();
  } catch (_) {
    // audio init fail — app vẫn chạy bình thường, chỉ không có âm thanh
  }

  // Khởi tạo notification plugin + timezone (không xin quyền ở đây —
  // chỉ xin khi user chủ động bật switch trong Cài đặt).
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // notification init fail — app vẫn chạy, chỉ không có nhắc nhở
  }

  runApp(const VocabQuestApp());
}

class VocabQuestApp extends StatelessWidget {
  const VocabQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (_) => GameProvider(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider()..load(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'VocabQuest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
            settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: <String, WidgetBuilder>{
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeScreen(),
              '/games': (_) => const GameMenuScreen(),
              '/history': (_) => const HistoryScreen(),
              '/leaderboard': (_) => const LeaderboardScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/shop': (_) => const ShopScreen(),
              '/favorites': (_) => const FavoritesScreen(),
            },
          );
        },
      ),
    );
  }
}