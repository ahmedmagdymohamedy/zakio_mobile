import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClickableWidget extends StatefulWidget {
  final Widget child;

  /// When null the widget is disabled: no press animation and no haptics.
  final VoidCallback? onTap;
  final Color? shadowColor;
  const ClickableWidget({
    super.key,
    required this.child,
    required this.onTap,
    this.shadowColor,
  });

  @override
  State<ClickableWidget> createState() => _ClickableWidgetState();
}

class _ClickableWidgetState extends State<ClickableWidget> {
  static const double gap = 5;
  double offsetY = -gap;

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      offsetY = 0;
    });
  }

  void _onTapUp(TapUpDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      offsetY = -gap;
    });
  }

  void _onTapCancel() {
    HapticFeedback.lightImpact();
    setState(() {
      offsetY = -gap;
    });
  }

  @override
  void didUpdateWidget(covariant ClickableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If it gets disabled mid-press (e.g. starts loading), don't stay pressed.
    if (widget.onTap == null) offsetY = -gap;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      onTap: widget.onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: widget.shadowColor ?? Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, offsetY, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
