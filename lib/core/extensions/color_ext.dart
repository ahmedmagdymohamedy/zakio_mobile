import 'package:flutter/material.dart';
import 'package:zakio/core/resources/app_colors.dart';

extension ColorExt on Color {
  Color getForegroundColorBasedOnBackgroundColor() {
    // If color is fully transparent, return black
    if (a == 0.0) return AppColors.primary;
    // Calculate the luminance to determine brightness
    return computeLuminance() > 0.3 ? AppColors.primary : Colors.white;
  }
}
