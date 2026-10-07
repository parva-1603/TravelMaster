import 'dart:async';
import 'package:flutter/material.dart';

class AutoSlideshowImage extends StatefulWidget {
  final List<String> images;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration interval;
  final bool showControls;

  const AutoSlideshowImage({
    super.key,
    required this.images,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.interval = const Duration(seconds: 5),
    this.showControls = true,
  });

  @override
  State<AutoSlideshowImage> createState() => _AutoSlideshowImageState();
}

class _AutoSlideshowImageState extends State<AutoSlideshowImage> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.images.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.images.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToIndex(int index) {
    setState(() {
      _currentIndex = index % widget.images.length;
    });
    _startTimer(); // Reset 5s countdown when manually tapped
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: widget.borderRadius,
        ),
      );
    }

    final validImages = widget.images.where((img) => img.trim().isNotEmpty).toList();
    if (validImages.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: widget.borderRadius,
        ),
      );
    }

    final currentUrl = validImages[_currentIndex % validImages.length];

    Widget currentImageWidget = ClipRRect(
      key: ValueKey<String>('$currentUrl-$_currentIndex'),
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Image.network(
        currentUrl,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.teal.shade900,
          child: const Center(
            child: Icon(Icons.photo_library_rounded, color: Colors.white54, size: 36),
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 950),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.06, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          child: currentImageWidget,
        ),
        if (validImages.length > 1 && widget.showControls) ...[
          // Bottom Indicator Dots
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                validImages.length,
                (i) => GestureDetector(
                  onTap: () => _goToIndex(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == (_currentIndex % validImages.length) ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == (_currentIndex % validImages.length)
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
