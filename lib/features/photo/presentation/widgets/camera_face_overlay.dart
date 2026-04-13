import 'package:flutter/material.dart';
import 'package:tasveer_ai/core/constants/app_colors.dart';

class CameraFaceOverlay extends StatelessWidget {
  const CameraFaceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final diameter = size.width * 0.72;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  holeRect: Rect.fromCenter(
                    center: Offset(size.width / 2, size.height / 2),
                    width: diameter,
                    height: diameter,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2.4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.holeRect});

  final Rect holeRect;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addOval(holeRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.58),
    );

    final guidePaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(holeRect, guidePaint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect;
  }
}
