import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/utils/color.dart';

class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key});

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  Offset position = Offset(0, 0); // 初始位置为试图A的中心

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
                onPanUpdate: (details) {
                  // 更新圆点的位置
                  setState(() {
                    position += details.delta;
                    // 限制圆点在试图A内部移动
                    position = Offset(
                      position.dx.clamp(
                          -((Constants.screenWidth(context) - 40 )/ 2.0),
                          ((Constants.screenWidth(context) - 40)) / 2.0),
                      position.dy.clamp(
                          -((Constants.screenWidth(context) - 40) / 2.0),
                          ((Constants.screenWidth(context) - 40) / 2.0)),
                    );
                    print('(Constants.screenWidth(context) - 40 / 2.0)=${((Constants.screenWidth(context) - 40 )/ 2.0)}');
                    print('details.delta.dx;=${position.dx}');
                    print('details.delta.dy;=${position.dy}');

                  });
                },
                onPanEnd: (details) {
                  // 手指松开时，将圆点移动回试图A的中心
                  setState(() {
                    position = Offset(0, 0);
                  });
                },
                child: Transform.translate(
                  offset: position,
                  child: Image(
                    image: AssetImage('images/connect/control_point.png'),
                    height: 44,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
