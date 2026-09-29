import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiveBackground extends StatefulWidget {
  final Widget child;

  const LiveBackground({super.key, required this.child});

  @override
  _LiveBackgroundState createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background color
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        // Animated gradient blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: -100 + 50 * math.sin(_controller.value * 2 * math.pi),
                  left: -50 + 50 * math.cos(_controller.value * 2 * math.pi),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 + 80 * math.cos(_controller.value * 2 * math.pi),
                  right: -100 + 80 * math.sin(_controller.value * 2 * math.pi),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Glass overlay or just the child
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}
