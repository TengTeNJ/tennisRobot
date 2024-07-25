import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/trainmode/robot_camera_rotate_view.dart';
import 'package:tennis_robot/trainmode/robot_rotate_view.dart';

/// 休息模式下 机器人軌跡view
class TrainModeTotalView extends StatefulWidget {
  const TrainModeTotalView({super.key});

  @override
  State<TrainModeTotalView> createState() => _TrainModeTotalViewState();
}

class _TrainModeTotalViewState extends State<TrainModeTotalView> {
  double _turns = 0.1;
  double _leftMargin = 10;
  double _topMargin = 181;

  Widget get rectBorderWidget {
    return DottedBorder(
      dashPattern: [8, 8],
      strokeWidth: 2,
      color: Constants.selectedModelBgColor,
      child: Container(
        width: Constants.screenWidth(context) - 32,
        height: Constants.screenWidth(context) - 32,
        color: Color.fromRGBO(77, 35, 10, 0.3),
      ),
    );
  }

  /// 生成随机位置的网球
  Widget get getRandomTenniss {
    return  Positioned(
      left: Constants.randomNumberLeftMargin(300) + 18,
      top: Constants.randomNumberTopMargin(300) + 0,
      child:Container(
        width: 8,
        height: 8,
        child: Image(image: AssetImage('images/resetmode/tennis_many_icon.png'),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for(int i = 0; i < 200 ; i ++)
          getRandomTenniss,
          rectBorderWidget,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
         child: const Text("right"),
          onPressed: () {
            setState(() {
              _leftMargin += 1;
              _topMargin += 1;
              // _turns -= 0.02;
            });
          },
        ),
        Positioned(
            left: _leftMargin,
            top: _topMargin,
            child: RobotRotateView(
              turns: _turns,
              duration: 1000,
              child: RobotCameraRotateView(),
            )
        ),
      ],
    );
  }
}
