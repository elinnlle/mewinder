import 'dart:math';
import 'package:flutter/material.dart';

/// Обёртка для анимированного фона с лапками.
class AnimatedPawsBackground extends StatefulWidget {
  final Widget child;

  const AnimatedPawsBackground({super.key, required this.child});

  @override
  State<AnimatedPawsBackground> createState() => _AnimatedPawsBackgroundState();
}

class _AnimatedPawsBackgroundState extends State<AnimatedPawsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final int pawCount = 14;
  final List<_Paw> paws = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _createPaws();
  }

  /// Создаём стартовые значения лапок
  void _createPaws() {
    final rnd = Random();

    for (int i = 0; i < pawCount; i++) {
      paws.add(
        _Paw(
          x: rnd.nextDouble(),
          y: rnd.nextDouble(),
          size: 46 + rnd.nextDouble() * 32,
          lifetime: 8 + rnd.nextDouble() * 4,
          rotationBase: rnd.nextDouble() * pi * 2,
          rotationSpeed: (rnd.nextDouble() - 0.5) * 0.20,
          dx: (rnd.nextDouble() - 0.5) * 0.005,
          dy: (rnd.nextDouble() - 0.5) * 0.005,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        painter: _PawsPainter(
          paws: paws,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Модель лапки для анимации
class _Paw {
  double x;
  double y;
  double size;
  double dx;
  double dy;
  double lifetime;
  double rotationBase;
  double rotationSpeed;
  double t = 0;

  _Paw({
    required this.x,
    required this.y,
    required this.size,
    required this.dx,
    required this.dy,
    required this.lifetime,
    required this.rotationBase,
    required this.rotationSpeed,
  });
}

/// Painter, который рисует и анимирует лапки
class _PawsPainter extends CustomPainter {
  final List<_Paw> paws;
  final Color color;
  final Random rnd = Random();

  _PawsPainter({required this.paws, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final paw in paws) {
      paw.t += 0.02;

      if (paw.t > paw.lifetime) {
        paw.t = 0;
        paw.x = rnd.nextDouble();
        paw.y = rnd.nextDouble();
      }

      final progress = paw.t / paw.lifetime;
      final fade = sin(progress * pi);

      final dx = paw.x * size.width + paw.dx * paw.t * 380;
      final dy = paw.y * size.height + paw.dy * paw.t * 380;
      final rotation = paw.rotationBase + paw.rotationSpeed * paw.t;

      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.pets.codePoint),
          style: TextStyle(
            fontSize: paw.size,
            fontFamily: Icons.pets.fontFamily,
            color: color.withValues(alpha: 0.30 * fade),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rotation);
      textPainter.paint(canvas, Offset(-paw.size / 2, -paw.size / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
