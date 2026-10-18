import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double navRailMin = 840; // bottom bar -> side rail
  static const double contentMax = 1200;

  static double hPad(double width, {double min = 16, double max = contentMax}) {
    final extra = (width - max) / 2;
    return extra > min ? extra : min;
  }

  /// 2 columns on phones, 3-5 on tablets / desktop / web.
  static const SliverGridDelegate productGrid =
      SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 230,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.62,
  );
}

/// Centres [child] and limits its width (forms, lists, settings).
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
