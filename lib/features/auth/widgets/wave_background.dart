import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WaveBackground extends StatefulWidget {
  final Widget child;
  const WaveBackground({super.key, required this.child});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                animation: _controller,
                waveColor1: AppColors.lightGreen.withOpacity(0.3),
                waveColor2: AppColors.accentGreen.withOpacity(0.2),
              ),
              child: Container(
                width: 200,
                height: 200,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor1;
  final Color waveColor2;

  WavePainter({
    required this.animation,
    required this.waveColor1,
    required this.waveColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY);

    // First wave
    final paint1 = Paint()
      ..color = waveColor1
      ..style = PaintingStyle.fill;

    final path1 = Path();
    for (var i = 0; i < 360; i++) {
      final radians = i * math.pi / 180;
      final wave = math.sin(radians * 4 + animation.value * 2 * math.pi);
      final waveRadius = radius + wave * 8;
      final x = centerX + math.cos(radians) * waveRadius;
      final y = centerY + math.sin(radians) * waveRadius;
      
      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave
    final paint2 = Paint()
      ..color = waveColor2
      ..style = PaintingStyle.fill;

    final path2 = Path();
    for (var i = 0; i < 360; i++) {
      final radians = i * math.pi / 180;
      final wave = math.sin(radians * 3 - animation.value * 2 * math.pi);
      final waveRadius = radius + wave * 10;
      final x = centerX + math.cos(radians) * waveRadius;
      final y = centerY + math.sin(radians) * waveRadius;
      
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
} 