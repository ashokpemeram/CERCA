import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

/// Animated SOS button widget
class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SosButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) {
          widget.onPressed();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed
              ? AppConstants.sosButtonPressedColor
              : AppConstants.sosButtonColor,
          boxShadow: [
            BoxShadow(
              color: AppConstants.sosButtonColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: widget.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scale(
            duration: const Duration(milliseconds: 1500),
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            duration: const Duration(milliseconds: 1500),
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            curve: Curves.easeInOut,
          ),
    );
  }
}
