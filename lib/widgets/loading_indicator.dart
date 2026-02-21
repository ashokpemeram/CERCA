import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

/// Reusable loading indicator widget with modern animations
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppConstants.primaryColor;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern pulsing circles animation
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: loadingColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 1500.ms,
                    )
                    .fade(begin: 0.5, end: 0.0, duration: 1500.ms),
                
                // Middle circle
                Container(
                  width: size * 0.7,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: loadingColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 1500.ms,
                      delay: 500.ms,
                    )
                    .fade(begin: 0.7, end: 0.0, duration: 1500.ms, delay: 500.ms),
                
                
                // App Logo in center
                Container(
                  width: size * 0.5,
                  height: size * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: loadingColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.08),
                      child: Image.asset(
                        'assets/images/CERCA.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(0.95, 0.95),
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              message!,
              style: AppConstants.bodyStyle.copyWith(
                color: loadingColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 800.ms)
                .then()
                .fadeOut(duration: 800.ms),
          ],
        ],
      ),
    );
  }
}
