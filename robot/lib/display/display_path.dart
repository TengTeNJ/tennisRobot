import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tennis_robot/basic/occupancy_map.dart';
import 'package:tennis_robot/provider/ros_channel.dart';

class DisplayPath extends CustomPainter {
  List<Offset> pointList = [];
  Color color = Colors.green;
  DisplayPath({required this.pointList, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color // 设置颜色为传入的颜色参数
      ..strokeCap = StrokeCap.butt // 设置画笔的端点为圆形，以便绘制圆形点
      ..strokeWidth = 1; // 设置画笔的宽度为1个像素
    canvas.drawPoints(PointMode.points, pointList, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
