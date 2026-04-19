import 'vocab_model.dart';

/// 📦 Model gói từ vựng theo chủ đề (mua được bằng coin)
class VocabPack {
  final String id;
  final String title;
  final String description;
  final String emoji;           // biểu tượng gói
  final List<String> gradient;  // hex color list cho card
  final int coinPrice;          // 0 = miễn phí
  final String level;           // beginner / intermediate / advanced
  final List<VocabModel> words;

  const VocabPack({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.coinPrice,
    required this.level,
    required this.words,
  });

  bool get isFree => coinPrice == 0;
  int get wordCount => words.length;

  factory VocabPack.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'] as List? ?? [];
    return VocabPack(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '📦',
      gradient: (json['gradient'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['#667EEA', '#764BA2'],
      coinPrice: (json['coinPrice'] as num?)?.toInt() ?? 0,
      level: json['level']?.toString() ?? 'beginner',
      words: rawWords
          .map((e) => VocabModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
