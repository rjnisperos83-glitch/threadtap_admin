import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// ThreadTap monogram + wordmark (vector, no asset needed).
class TtLogo extends StatelessWidget {
  const TtLogo({
    super.key,
    this.size = 84,
    this.showWordmark = true,
    this.light = false,
    this.tagline = 'WEAR SMARTER',
  });

  final double size;
  final bool showWordmark;
  final bool light;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'TT',
            style: AppTheme.serif(
              size: size * 0.42,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          Positioned(
            top: size * 0.16,
            right: size * 0.18,
            child: Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: const BoxDecoration(
                color: AppColors.lilac,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.2),
        Text(
          'THREADTAP',
          style: AppTheme.serif(
            size: size * 0.24,
            color: light ? Colors.white : AppColors.ink,
            letterSpacing: size * 0.06,
          ),
        ),
        if (tagline != null) ...[
          SizedBox(height: size * 0.04),
          Text(
            tagline!,
            style: TextStyle(
              fontSize: size * 0.1,
              letterSpacing: size * 0.05,
              color: light ? AppColors.lilac : AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}
