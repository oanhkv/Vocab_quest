import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../models/vocab_model.dart';
import '../models/vocab_pack_model.dart';

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

  /// Đọc danh sách gói từ vựng (shop)
  static Future<List<VocabPack>> loadPacks() async {
    try {
      final rawBase =
          await rootBundle.loadString('assets/data/vocab_packs.json');
      final baseDecoded = json.decode(rawBase);
      final packs = <VocabPack>[
        ..._parsePackList(baseDecoded),
      ];

      // Optional file: có thì merge thêm, không có thì bỏ qua.
      try {
        final rawExtra =
            await rootBundle.loadString('assets/data/vocab_extra_packs.json');
        final extraDecoded = json.decode(rawExtra);
        packs.addAll(_parsePackList(extraDecoded));
      } catch (_) {
        // ignore nếu dự án chưa có file extra
      }

      return packs;
    } catch (e) {
      debugPrint('Error loadPacks: $e');
      return [];
    }
  }

  static List<VocabPack> _parsePackList(dynamic decoded) {
    final List<dynamic> list = decoded is Map<String, dynamic>
        ? (decoded['packs'] as List? ?? [])
        : (decoded is List ? decoded : []);
    return list
        .map((e) => VocabPack.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
