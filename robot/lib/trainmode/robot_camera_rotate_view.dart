import 'package:flutter/material.dart';
import 'package:tennis_robot/trainmode/sector_painter.dart';

/// 旋转的机器人 + 摄像头
class RobotCameraRotateView extends StatefulWidget {
  const RobotCameraRotateView({super.key});

  @override
  State<RobotCameraRotateView> createState() => _RobotCameraRotateViewState();
}

class _RobotCameraRotateViewState extends State<RobotCameraRotateView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          child:Image.asset('images/connect/robot_icon.png',
            width: 50,
            height: 25,
            color: Colors.red,
          ),
        ),

        Container(
          color: Colors.blue,
          margin: EdgeInsets.only(left: 0),
          child: CustomPaint(
            size: const Size(100, 100),
            painter: SectorPainter(),
          ),
        ),
      ],

    );
  }
}
