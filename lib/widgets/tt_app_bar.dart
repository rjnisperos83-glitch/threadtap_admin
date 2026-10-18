import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Gradient header with softly rounded bottom corners.
class TtAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TtAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.brand = false,
    this.centerTitle = true,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;

  /// Shows the "ThreadTap" wordmark instead of a title.
  final bool brand;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 10 + (subtitle != null ? 12 : 0));

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(bottom: Radius.circular(26));
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: brand ? false : centerTitle,
      leading: leading,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shape: const RoundedRectangleBorder(borderRadius: radius),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: radius,
        ),
      ),
      title: brand
          ? Text('ThreadTap',
              style: AppTheme.serif(
                  size: 24, color: Colors.white, letterSpacing: .5))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title ?? '',
                    style: AppTheme.serif(size: 20, color: Colors.white)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.lilac)),
              ],
            ),
      actions: [...actions, const SizedBox(width: 6)],
    );
  }
}

/// Round translucent icon button for use in [TtAppBar.actions].
class TtIconAction extends StatelessWidget {
  const TtIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.showDot = false,
    this.badge = 0,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  final int badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip ?? '',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white.withValues(alpha: .16),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
              ),
            ),
            if (showDot && badge == 0)
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.lilac,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                ),
              ),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.orchid,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
