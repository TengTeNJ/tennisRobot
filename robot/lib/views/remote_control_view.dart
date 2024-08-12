import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/utils/color.dart';
import 'dart:math' as math;

import 'package:tennis_robot/utils/robot_manager.dart';

class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key});

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  Offset position = Offset(0, 0); // 初始位置为试图A的中心
  bool isMove = false; // 滑动标识
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Constants.screenWidth(context) - 40,
      height: Constants.screenWidth(context) - 40,
      decoration: BoxDecoration(
          color: hexStringToColor('#2B2C30'),
          borderRadius: BorderRadius.circular(
              (Constants.screenWidth(context) - 40) / 2.0)),
      child: Stack(
        children: [
          Center(
            child: Image(
              image: AssetImage('images/connect/remote_control.png'),
              height: Constants.screenWidth(context) - 40 - 96,
            ),
          ),
          Positioned(
              left: (Constants.screenWidth(context) - 40 - 44) / 2.0,
              top: (Constants.screenWidth(context) - 40 - 44) / 2.0,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    // 开始拖拽
                    isMove = true;
                  });
                },
                onPanUpdate: (details) {
                  // 更新圆点的位置
                  setState(() {
                    position += details.delta;
                    // 设置机器人角度
                    // RobotManager().setRobotAngle(30);
                    // position = Offset(
                    //   position.dx.clamp(
                    //       -(((Constants.screenWidth(context) - 40) / 2.0)),
                    //       ((Constants.screenWidth(context) - 40)) / 2.0),
                    //   position.dy.clamp(
                    //       -(((Constants.screenWidth(context) - 40) / 2.0)),
                    //       ((Constants.screenWidth(context) - 40) / 2.0)),
                    // );
                    // 限制圆点在试图A内部移动
                    position = _clampOffsetToCircle(position, ((Constants.screenWidth(context) - 40) / 2.0));

                  });
                },
                onPanEnd: (details) {
                  // 手指松开时，将圆点移动回试图A的中心
                  setState(() {
                    print('positions =-==--=${position}');
                    final single = math.tan(position.dy / position.dx);
                    var angle = math.atan2(position.dy, position.dx);
                    var degrees = angle * (180 / math.pi) + 90;
                    print('角度${degrees}');
                    RobotManager().setRobotAngle(degrees.toInt());
                    // 结束拖拽
                    position = Offset(0, 0);
                    isMove = false;
                  });
                },
                child: Transform.translate(
                  offset: position,
                  child: Image(
                    image: AssetImage(isMove
                        ? 'images/connect/control_point_move.png'
                        : 'images/connect/control_point.png'),
                    height: 44,
                  ),
                ),
              ))
        ],
      ),
    );
  }
  /*限制圆环在圆形内拖拽*/
  Offset _clampOffsetToCircle(Offset offset, double radius) {
    double distanceSquared = offset.dx * offset.dx + offset.dy * offset.dy;
    if (distanceSquared <= radius * radius) {
      // 如果已经在圆内或圆上，则无需调整
      return offset;
    } else {
      // 如果在圆外，则计算到圆边缘的最近点
      double distance = math.sqrt(distanceSquared);
      double x = offset.dx * radius / distance;
      double y = offset.dy * radius / distance;
      return Offset(x, y);
    }
  }
}
