import 'dart:math';
import 'package:flutter/material.dart';

class LikeBurst extends StatefulWidget {
  final VoidCallback onFinished;
  final Color color;

  const LikeBurst({super.key, required this.onFinished, required this.color});

  @override
  State<LikeBurst> createState() => _LikeBurstState();
}

class _LikeBurstState extends State<LikeBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_HeartParticle> hearts;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward().whenComplete(widget.onFinished);

    final rnd = Random();

    hearts = List.generate(5, (_) {
      final angle = rnd.nextDouble() * (pi / 3);
      final distance = 100 + rnd.nextDouble() * 60;

      return _HeartParticle(
        dx: cos(angle) * distance,
        dy: sin(angle) * distance,
        size: 24 + rnd.nextDouble() * 10,
        rotation: (rnd.nextDouble() - 0.5) * 0.8,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = _controller.value;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final h in hearts)
              Transform.translate(
                offset: Offset(h.dx * t, h.dy * t),
                child: Transform.rotate(
                  angle: h.rotation * t,
                  child: Opacity(
                    opacity: (1 - t).clamp(0, 1),
                    child: Text(
                      '❤️',
                      style: TextStyle(fontSize: h.size, color: widget.color),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _HeartParticle {
  final double dx;
  final double dy;
  final double size;
  final double rotation;

  _HeartParticle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
  });
}
