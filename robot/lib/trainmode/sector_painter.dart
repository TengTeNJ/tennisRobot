import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// 扇形
class SectorPainter extends CustomPainter {

  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color.fromRGBO(233, 100, 21, 0.6)
      ..style = PaintingStyle.fill;
    print(size.width);
    final Rect rect = Rect.fromLTWH(-120,0, size.width , size.height);
    final double startAngle = - pi / 4; // 90度处开始
    final double sweepAngle =  pi / 2; // 90度扇形

   // Offset
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    // canvas.drawCircle(Offset(size.width/2, size.height/2), 20, paint);
    // canvas.drawOval(rect, paint);

    // Rect rect1 = Rect.fromPoints(const Offset(50, 200), const Offset(320, 600));
    // RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50.0));
    // canvas.drawRRect(rrect, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}