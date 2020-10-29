import 'package:flutter/material.dart';

class ArrowCustomPainter extends CustomPainter {
  final BuildContext context;

  ArrowCustomPainter(this.context);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Theme.of(context).hintColor;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(trianglePath(Offset(baseX - 4.0, baseY - 2.0), width, height, true), paint);
    canvas.drawPath(trianglePath(Offset(baseX - 4.0, baseY + 2.0), width, height, false), paint);
  }

  static Path trianglePath(Offset offset, double width, double height, bool isUp) {
    return Path()
      ..moveTo(offset.dx, offset.dy)
      ..lineTo(offset.dx + width, offset.dy)
      ..lineTo(offset.dx + (width / 2), isUp ? offset.dy - height : offset.dy + height)
      ..close();
  }
}
