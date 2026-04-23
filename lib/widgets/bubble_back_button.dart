import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

/// 🔘 Nút back dạng bubble tròn có shadow — dùng chung trong AppBar toàn app
class BubbleBackButton extends StatelessWidget {
  final Color? bg;
  final Color? iconColor;
  final VoidCallback? onTap;
  const BubbleBackButton({super.key, this.bg, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final defaultBg = Theme.of(context).cardTheme.color ?? Colors.white;
    final defaultIcon = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          decoration: BoxDecoration(
            color: bg ?? defaultBg,
            shape: BoxShape.circle,
            boxShadow: AppShadow.soft,
          ),
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: iconColor ?? defaultIcon,
          ),
        ),
      ),
    );
  }
}
