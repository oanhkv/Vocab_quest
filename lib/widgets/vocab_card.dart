import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../models/vocab_model.dart';

/// 📖 Card hiển thị 1 từ vựng với hình ảnh
/// Có thể tap để phát âm (TTS)
class VocabCard extends StatelessWidget {
  final VocabModel vocab;
  final VoidCallback? onTap;
  final bool showMeaning;       // Hiển thị nghĩa hay không
  final bool showExample;       // Hiển thị câu ví dụ
  final List<Color>? gradient;
  final double? height;

  const VocabCard({
    super.key,
    required this.vocab,
    this.onTap,
    this.showMeaning = true,
    this.showExample = false,
    this.gradient,
    this.height,
  });

  /// Phát âm từ bằng Text-to-Speech
  Future<void> _speak(String text) async {
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final cardGradient = gradient ?? AppColors.gradientPurple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: cardGradient.first.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hình ảnh / emoji
            Center(child: _buildImage()),
            const SizedBox(height: 12),

            // Từ tiếng Anh + nút phát âm
            Row(
              children: [
                Expanded(
                  child: Text(
                    vocab.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _speak(vocab.word),
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.volumeHigh,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            // Phiên âm
            if (vocab.pronunciation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  vocab.pronunciation,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),

            // Nghĩa tiếng Việt
            if (showMeaning && vocab.meaning.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  vocab.meaning,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            // Câu ví dụ
            if (showExample && vocab.example.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '"${vocab.example}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Render hình ảnh - hỗ trợ emoji, network, asset
  Widget _buildImage() {
    // Nếu là emoji (không phải URL và chuỗi ngắn)
    if (vocab.isEmoji) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Text(
          vocab.image,
          style: const TextStyle(fontSize: 48),
        ),
      );
    }

    // Nếu là URL
    if (vocab.isNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: CachedNetworkImage(
          imageUrl: vocab.image,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 100,
            width: 100,
            color: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.image, color: Colors.white54),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: const Icon(Icons.broken_image,
                color: Colors.white54, size: 36),
          ),
        ),
      );
    }

    // Nếu là asset
    if (vocab.isAssetImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Image.asset(
          vocab.image,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultImageBox(),
        ),
      );
    }

    return _defaultImageBox();
  }

  Widget _defaultImageBox() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: const Icon(
        FontAwesomeIcons.book,
        color: Colors.white,
        size: 36,
      ),
    );
  }
}

/// 📱 Card nhỏ gọn hiển thị từ vựng (dùng trong list)
class VocabListTile extends StatelessWidget {
  final VocabModel vocab;
  final VoidCallback? onTap;

  const VocabListTile({
    super.key,
    required this.vocab,
    this.onTap,
  });

  Future<void> _speak(String text) async {
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ảnh/emoji
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientPurple,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Center(
                  child: vocab.isEmoji
                      ? Text(vocab.image,
                      style: const TextStyle(fontSize: 28))
                      : const Icon(FontAwesomeIcons.book,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocab.word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (vocab.pronunciation.isNotEmpty)
                      Text(
                        vocab.pronunciation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      vocab.meaning,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút phát âm
              IconButton(
                onPressed: () => _speak(vocab.word),
                icon: const Icon(
                  FontAwesomeIcons.volumeHigh,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎴 Flashcard lật được (front/back)
class FlippableVocabCard extends StatefulWidget {
  final VocabModel vocab;
  final List<Color>? gradient;

  const FlippableVocabCard({
    super.key,
    required this.vocab,
    this.gradient,
  });

  @override
  State<FlippableVocabCard> createState() => _FlippableVocabCardState();
}

class _FlippableVocabCardState extends State<FlippableVocabCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          final isBack = angle > 3.14159 / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(3.14159),
              child: _buildBack(),
            )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return VocabCard(
      vocab: widget.vocab,
      showMeaning: false,
      gradient: widget.gradient,
      height: 280,
    );
  }

  Widget _buildBack() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradient ?? AppColors.gradientPink,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.language,
              color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            widget.vocab.meaning,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.vocab.example.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '"${widget.vocab.example}"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}