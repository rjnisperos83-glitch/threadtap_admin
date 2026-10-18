import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum TtButtonStyle { filled, outlined, tonal, danger, light }

class TtButton extends StatelessWidget {
  const TtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = TtButtonStyle.filled,
    this.loading = false,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TtButtonStyle style;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (style) {
      case TtButtonStyle.filled:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case TtButtonStyle.tonal:
        bg = AppColors.tint;
        fg = AppColors.primary;
        break;
      case TtButtonStyle.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        break;
      case TtButtonStyle.light:
        bg = Colors.white;
        fg = AppColors.primary;
        break;
      case TtButtonStyle.outlined:
        bg = Colors.transparent;
        fg = AppColors.primary;
        break;
    }

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Flexible(
                child: Text(label,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const textStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 15);

    final Widget button = style == TtButtonStyle.outlined
        ? OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: fg,
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              shape: shape,
              textStyle: textStyle,
            ),
            child: content,
          )
        : ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              disabledBackgroundColor: AppColors.lilac.withValues(alpha: .45),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: shape,
              textStyle: textStyle,
            ),
            child: content,
          );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: button,
    );
  }
}
