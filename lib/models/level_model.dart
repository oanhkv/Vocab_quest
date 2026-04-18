import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 🎯 Model cấp độ
class LevelModel {
  final String id;
  final String name;          // Tên hiển thị
  final String description;   // Mô tả
  final Color color;
  final IconData icon;
  final List<Color> gradient;

  const LevelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.gradient,
  });

  static const levels = [
    LevelModel(
      id: 'beginner',
      name: 'Sơ cấp',
      description: 'Từ vựng cơ bản cho người mới',
      color: AppColors.beginnerColor,
      icon: Icons.eco,
      gradient: AppColors.gradientGreen,
    ),
    LevelModel(
      id: 'intermediate',
      name: 'Trung cấp',
      description: 'Mở rộng vốn từ',
      color: AppColors.intermediateColor,
      icon: Icons.local_fire_department,
      gradient: AppColors.gradientOrange,
    ),
    LevelModel(
      id: 'advanced',
      name: 'Nâng cao',
      description: 'Thử thách trình độ cao',
      color: AppColors.advancedColor,
      icon: Icons.bolt,
      gradient: AppColors.gradientPink,
    ),
  ];

  static LevelModel getById(String id) {
    return levels.firstWhere((l) => l.id == id, orElse: () => levels[0]);
  }
}