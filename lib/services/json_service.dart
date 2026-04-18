import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../models/vocab_model.dart';

/// 📄 Service đọc dữ liệu JSON từ assets
class JsonService {
  /// Đọc từ vựng theo level
  static Future<List<VocabModel>> loadVocab(String level) async {
    try {
      String path;
      switch (level) {
        case 'intermediate':
          path = AppConstants.vocabIntermediateJson;
          break;
        case 'advanced':
          path = AppConstants.vocabAdvancedJson;
          break;
        default:
          path = AppConstants.vocabBeginnerJson;
      }

      final String response = await rootBundle.loadString(path);
      final dynamic decoded = json.decode(response);
      final List<dynamic> words = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> ? (decoded['words'] ?? []) : []);

      return words
          .map((e) => VocabModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('Error loading JSON $level: $e');
      return [];
    }
  }

  /// Đọc tất cả từ vựng
  static Future<List<VocabModel>> loadAllVocab() async {
    final beginner = await loadVocab('beginner');
    final intermediate = await loadVocab('intermediate');
    final advanced = await loadVocab('advanced');
    return [...beginner, ...intermediate, ...advanced];
  }

  /// Đọc từ vựng theo chủ đề
  static Future<List<VocabModel>> loadVocabByCategory(String category) async {
    final all = await loadAllVocab();
    return all.where((v) => v.category == category).toList();
  }
}