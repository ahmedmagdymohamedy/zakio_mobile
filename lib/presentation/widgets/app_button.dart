import 'package:flutter/material.dart';
import 'package:zakio/core/resources/app_fonts.dart';
import 'package:zakio/presentation/widgets/clickable_widget.dart';

/// The shared app button (the splash "Get Started" style) built on [ClickableWidget].
///
/// Pass `onTap: null` to disable it, or `isLoading: true` to show a loader and ignore taps.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double width;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.height = 60,
    this.width = double.infinity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    final Color foregroundColor = textColor ?? Colors.white;

    return ClickableWidget(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDisabled ? Theme.of(context).disabledColor : (backgroundColor ?? Colors.green),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isLoading
              ? SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: foregroundColor),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.titlesFont(context),
                  ),
                ),
        ),
      ),
    );
  }
}
