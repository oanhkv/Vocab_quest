/// 📖 Model từ vựng
class VocabModel {
  final String id;
  final String word;           // Từ tiếng Anh
  final String meaning;        // Nghĩa tiếng Việt
  final String pronunciation;  // Phiên âm
  final String image;          // URL hoặc path ảnh
  final String example;        // Câu ví dụ
  final String category;       // Chủ đề (animal, food, ...)
  final String level;          // beginner / intermediate / advanced

  VocabModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.image,
    required this.example,
    required this.category,
    this.level = 'beginner',
  });

  factory VocabModel.fromJson(Map<String, dynamic> json) {
    return VocabModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      image: json['image'] ?? '',
      example: json['example'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'meaning': meaning,
    'pronunciation': pronunciation,
    'image': image,
    'example': example,
    'category': category,
    'level': level,
  };

  /// Kiểm tra xem image là URL hay icon emoji
  bool get isEmoji => !image.startsWith('http') && image.length <= 4;
  bool get isNetworkImage => image.startsWith('http');
  bool get isAssetImage => image.startsWith('assets/');
}