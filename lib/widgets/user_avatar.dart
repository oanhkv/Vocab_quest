import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 🖼️ Avatar hiển thị ảnh user: hỗ trợ data URI base64, URL http(s),
/// fallback chữ cái đầu khi thiếu.
class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String displayName;
  final double radius;

  /// Màu nền khi hiển thị chữ cái đầu.
  final Color backgroundColor;

  /// Màu chữ khi hiển thị chữ cái đầu.
  final Color textColor;

  /// Tỷ lệ cỡ chữ so với bán kính. Mặc định 0.9.
  final double fontScale;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    this.radius = 24,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.primary,
    this.fontScale = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'U';

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * fontScale,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );

    if (avatarUrl.isEmpty) return fallback;

    final size = radius * 2;

    // Data URI (base64) — decode một lần rồi render bằng Image.memory.
    if (avatarUrl.startsWith('data:image/')) {
      final bytes = _decodeDataUri(avatarUrl);
      if (bytes == null) return fallback;
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }

    // URL http(s) — cache qua CachedNetworkImage.
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  Uint8List? _decodeDataUri(String uri) {
    try {
      final comma = uri.indexOf(',');
      if (comma < 0) return null;
      return base64Decode(uri.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
}
