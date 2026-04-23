import '../models/vocab_model.dart';
import '../models/vocab_pack_model.dart';
import 'json_service.dart';

/// 📚 Service tổng hợp gói từ vựng (built-in free + gói mua từ shop)
class PackService {
  static const List<String> builtinIds = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  /// 3 gói free được tích hợp sẵn (từ vựng load từ 3 file JSON cũ)
  static List<VocabPack> builtinPacks() {
    return const [
      VocabPack(
        id: 'beginner',
        title: 'Sơ cấp',
        description: '250+ từ vựng cơ bản hàng ngày',
        emoji: '🌱',
        gradient: ['#43E97B', '#38F9D7'],
        coinPrice: 0,
        level: 'beginner',
        words: [],
      ),
      VocabPack(
        id: 'intermediate',
        title: 'Trung cấp',
        description: 'Từ vựng nâng cao hơn',
        emoji: '🔥',
        gradient: ['#FA709A', '#FEE140'],
        coinPrice: 0,
        level: 'intermediate',
        words: [],
      ),
      VocabPack(
        id: 'advanced',
        title: 'Nâng cao',
        description: 'Từ vựng thử thách',
        emoji: '💎',
        gradient: ['#667EEA', '#764BA2'],
        coinPrice: 0,
        level: 'advanced',
        words: [],
      ),
    ];
  }

  /// Tải danh sách gói người dùng sở hữu (built-in + gói free + gói đã mua)
  /// Mọi gói có `coinPrice == 0` được tự động coi là đã sở hữu.
  static Future<List<VocabPack>> loadOwnedPacks(List<String> ownedIds) async {
    final builtins =
        builtinPacks().where((p) => ownedIds.contains(p.id)).toList();
    final all = await JsonService.loadPacks();
    final visible =
        all.where((p) => p.isFree || ownedIds.contains(p.id)).toList();
    return [...builtins, ...visible];
  }

  /// Tải toàn bộ từ vựng của 1 pack
  static Future<List<VocabModel>> loadPackWords(VocabPack pack) async {
    if (builtinIds.contains(pack.id)) {
      return JsonService.loadVocab(pack.id);
    }
    return pack.words;
  }

  /// Chia từ vựng theo level (1-3) của 1 pack.
  /// Level 1: nửa đầu (dễ) · Level 2: nửa sau · Level 3: toàn bộ (shuffled)
  static List<VocabModel> wordsForLevel(List<VocabModel> all, int level) {
    if (all.isEmpty) return [];
    final copy = List<VocabModel>.from(all);
    final half = (copy.length / 2).ceil();
    switch (level) {
      case 1:
        return copy.take(half).toList();
      case 2:
        return copy.skip(half).toList().isEmpty
            ? copy
            : copy.skip(half).toList();
      case 3:
      default:
        copy.shuffle();
        return copy;
    }
  }

  /// Số level trong 1 pack (hiện tại cố định 3)
  static const int levelsPerPack = 3;

  /// Tải 1 pack theo id (ưu tiên builtin, fallback JSON packs).
  static Future<VocabPack?> loadPackById(String packId) async {
    final builtin = builtinPacks().where((p) => p.id == packId).toList();
    if (builtin.isNotEmpty) return builtin.first;

    final packs = await JsonService.loadPacks();
    for (final p in packs) {
      if (p.id == packId) return p;
    }
    return null;
  }
}
