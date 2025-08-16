import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileBackgroundPainter extends CustomPainter {
  final double rotationValue;
  final double sparkleValue;
  final Color primaryColor;

  ProfileBackgroundPainter({
    required this.rotationValue,
    required this.sparkleValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primaryColor.withOpacity(0.1);

    // Draw animated geometric patterns
    for (int i = 0; i < 20; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (rotationValue * 50),
        (size.height * 0.1 * i) + (sparkleValue * 30),
      );

      canvas.drawCircle(
        offset,
        20 + (sparkleValue * 10),
        paint,
      );
    }

    // Draw rotating hexagons
    final hexPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = primaryColor.withOpacity(0.05);

    for (int i = 0; i < 10; i++) {
      final center = Offset(
        size.width * (0.2 + 0.6 * math.Random(i).nextDouble()),
        size.height * (0.2 + 0.6 * math.Random(i + 50).nextDouble()),
      );

      _drawHexagon(canvas, center, 40 + (i * 5), hexPaint, rotationValue);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint, double rotation) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i + (rotation * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ProfileBackgroundPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.sparkleValue != sparkleValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class ProfileParticlesPainter extends CustomPainter {
  final double animationValue;
  final double floatingValue;
  final Color primaryColor;

  ProfileParticlesPainter({
    required this.animationValue,
    required this.floatingValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(0.3);

    // Draw floating particles
    for (int i = 0; i < 50; i++) {
      final x = (size.width * math.Random(i).nextDouble()) + 
          (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * math.Random(i + 100).nextDouble()) + 
          (math.cos(animationValue * 2 * math.pi + i) * 15) + floatingValue;

      final radius = 2 + (math.sin(animationValue * 4 * math.pi + i) * 1);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // Draw sparkle effects
    final sparklePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(0.6);

    for (int i = 0; i < 20; i++) {
      final sparkleX = size.width * math.Random(i + 200).nextDouble();
      final sparkleY = size.height * math.Random(i + 300).nextDouble();
      final sparkleSize = 1 + (math.sin(animationValue * 6 * math.pi + i) * 2);

      if (sparkleSize > 1.5) {
        _drawStar(canvas, Offset(sparkleX, sparkleY), sparkleSize, sparklePaint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final double innerRadius = size * 0.5;
    final double outerRadius = size;

    for (int i = 0; i < 10; i++) {
      final double angle = (math.pi / 5) * i;
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ProfileParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.floatingValue != floatingValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}
