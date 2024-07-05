import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/trainmode/robot_camera_rotate_view.dart';

/// 休息模式下机器人
class TrainModeTotalView extends StatefulWidget {
  const TrainModeTotalView({super.key});

  @override
  State<TrainModeTotalView> createState() => _TrainModeTotalViewState();
}

class _TrainModeTotalViewState extends State<TrainModeTotalView> {
  Widget get rectBorderWidget {
    return DottedBorder(
      dashPattern: [8, 8],
      strokeWidth: 2,
      color: Constants.selectedModelBgColor,
      child: Container(
        width: 354,
        height: 354,
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
        Positioned(
            left: 135,
            top: 181,
            child: Container(
              child: RobotCameraRotateView(),
            )
        ),
        for(int i = 0; i < 100 ; i ++)
          getRandomTenniss,
         rectBorderWidget,

      ],
    );
  }
}
