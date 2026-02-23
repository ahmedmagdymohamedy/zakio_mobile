import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ClickableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
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
