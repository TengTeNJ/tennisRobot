import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tennis_robot/constant/constants.dart';

/**
 * 机器人轨迹VIew
 */
class RobotRouteView extends StatefulWidget {
  const RobotRouteView({super.key});

  @override
  State<RobotRouteView> createState() => _RobotRouteViewState();
}

class _RobotRouteViewState extends State<RobotRouteView> {
  Widget get rectBorderWidget {
    return DottedBorder(
      dashPattern: [8, 8],
      strokeWidth: 2,
      color: Constants.selectedModelBgColor,
      child: Container(
        width: 354,
        height: 60,
        color: Color.fromRGBO(77, 35, 10, 0.3),
      ),
    );
  }


  Widget get getRobotIconWidget {
     return Container(
           alignment: Alignment.center,
           width: 50,
           height: 25,
           child: Image(image: AssetImage('images/connect/robot_icon.png'),),
     );
  }
  /// 生成随机位置的网球
  Widget get getRandomTenniss {
    return  Positioned(
      left: Constants.randomNumberLeftMargin() + 63,
      top: Constants.randomNumberTopMargin() + 0,
      child:Container(
        width: 8,
        height: 8,
        child: Image(image: AssetImage('images/resetmode/tennis_many_icon.png'),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 0),
      child: Stack(
        children: <Widget>[
           rectBorderWidget,
          Positioned(
           left: 24,
           top: 18,
           child: Container(
             alignment: Alignment.center,
             width: 50,
             height: 25,
             child: Image(image: AssetImage('images/connect/robot_icon.png'),),
           ),
         ) ,
         Positioned(
           left: 63,
           top: 0,
           child: Container(
             color: Color.fromRGBO(233, 100, 21, 0.6),width:40 ,height: 64,
           ),
         ),
         for(int i = 0; i < 10 ; i ++)
           getRandomTenniss,
        ],
      ),
    );
  }
}
