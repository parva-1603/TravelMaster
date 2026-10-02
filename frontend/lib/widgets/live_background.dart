import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiveBackground extends StatefulWidget {
  final Widget child;

  const LiveBackground({super.key, required this.child});

  @override
  State<LiveBackground> createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: _RouteMapPainter(
                  progress: _controller.value,
                  lineColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  _RouteMapPainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var index = 0; index < 11; index++) {
      final y = size.height * (0.28 + index * 0.075);
      final drift = math.sin(progress * 2 * math.pi + index * 0.42) * 14;
      final path = Path()
        ..moveTo(-30, y + drift)
        ..cubicTo(
          size.width * 0.24,
          y - 58 + drift,
          size.width * 0.42,
          y + 72 - drift,
          size.width * 0.68,
          y + 12,
        )
        ..cubicTo(
          size.width * 0.84,
          y - 22 - drift,
          size.width * 0.94,
          y + 45 + drift,
          size.width + 30,
          y - 2,
        );
      canvas.drawPath(path, contourPaint);
    }

    final route = Path()
      ..moveTo(size.width * 0.12, size.height * 0.82)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.68,
        size.width * 0.61,
        size.height * 0.94,
        size.width * 0.88,
        size.height * 0.72,
      );
    final routePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(route, routePaint);

    final routeMetric = route.computeMetrics().first;
    final point =
        routeMetric.getTangentForOffset(routeMetric.length * progress);
    if (point != null) {
      canvas.drawCircle(
        point.position,
        4,
        Paint()..color = lineColor.withValues(alpha: 0.62),
      );
      canvas.drawCircle(
        point.position,
        8,
        Paint()..color = lineColor.withValues(alpha: 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.lineColor != lineColor;
}
