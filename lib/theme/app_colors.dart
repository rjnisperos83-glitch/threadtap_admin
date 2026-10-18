import 'package:flutter/material.dart';

/// ThreadTap palette ("Purple Blend").
/// #2B103C  #3D2A5D  #572866  #8F529B  #AC91C0
class AppColors {
  AppColors._();

  static const ink = Color(0xFF2B103C);
  static const plum = Color(0xFF3D2A5D);
  static const primary = Color(0xFF572866);
  static const orchid = Color(0xFF8F529B);
  static const lilac = Color(0xFFAC91C0);

  // Neutrals derived from the palette
  static const mist = Color(0xFFF7F3FA); // page background
  static const tint = Color(0xFFEEE6F4); // soft fills / chips
  static const border = Color(0xFFE3D9EB);
  static const surface = Colors.white;
  static const text = Color(0xFF241132);
  static const muted = Color(0xFF7D6E8B);

  // Status colours
  static const success = Color(0xFF2E9E6B);
  static const warning = Color(0xFFE29A2D);
  static const danger = Color(0xFFC0392B);

  static const headerGradient = LinearGradient(
    colors: [ink, plum, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const brandGradient = LinearGradient(
    colors: [plum, primary, orchid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
