
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/models/robot_data_model.dart';
import 'package:tennis_robot/trainmode/mode_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_function_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_move_view.dart';
import 'package:tennis_robot/trainmode/robot_route_view.dart';
import 'package:tennis_robot/trainmode/train_mode_total_view.dart';
import 'package:tennis_robot/utils/dialog.dart';
import 'package:tennis_robot/utils/robot_send_data.dart';
import 'package:tennis_robot/views/button_switch_view.dart';
import 'package:tennis_robot/views/remote_control_view.dart';
import 'package:tennis_robot/utils/navigator_util.dart';
import 'package:tennis_robot/utils/robot_manager.dart';
import 'package:tennis_robot/utils/data_base.dart';

import '../models/ball_model.dart';

/// 训练模式
class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  int mode = 0;
  int powerLevels = 5;
  int robotLeftMargin = 0;
  int robotTopMargin = 0;
  int robotAngle = 0;
  List<BallModel> trueBallList = []; // 视野中看到的真实的球
  int restModeTotalViewTopMargin = -60; // 休息模式下整体 topMargin
  void modeChange(int index) {
    setState(() {
      mode = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print('66666${RobotManager().manualFetch(ManualFetchType.device)}');
    // 监听电量
    RobotManager().dataChange = (TCPDataType type) {
      // setState(() {
      int power = RobotManager().dataModel.powerValue;
      power = 68;
      if (0<power && power<20) {
        powerLevels = 1;
      } else if (20<power && power < 40){
        powerLevels = 2;
      } else if (40<power &&power <60) {
        powerLevels = 3;
      } else if (60<power &&power <80) {
        powerLevels = 4;
      } else {
        powerLevels = 5;
      }
      // });
      if (type == TCPDataType.deviceInfo) {
        print('robot battery ${RobotManager().dataModel.powerValue}');
      } else if(type == TCPDataType.speed) {
        print('robot speed ${RobotManager().dataModel.speed}');
      } else if(type == TCPDataType.coordinate) { // 机器人坐标
        // 机器人X坐标
        int xPoint = RobotManager().dataModel.xPoint;
        // 机器人Y坐标
        int yPoint = RobotManager().dataModel.yPoint;
        // 机器人角度
        int robotAngle = RobotManager().dataModel.angle;

        // 机器人坐标转换
        xPoint = 10; yPoint = 100;
          // setState(() {
          //   robotLeftMargin = xPoint + 44;
          //   robotTopMargin = yPoint + 68;
          // });
          setState(() {
            robotLeftMargin += 4;
            robotTopMargin += 4;
            robotAngle += 1;
          });

        print('robot coordinate ${xPoint}  ${yPoint} ${robotAngle}');
      } else if(type == TCPDataType.ballsInView) { // 视野中看到的球
        List balls = RobotManager().dataModel.inViewBallList;
        var ball = BallModel();
        ball.xPoint = 200;
        ball.yPoint = 200;
        trueBallList.add(ball);
        trueBallList.addAll(balls as Iterable<BallModel>);
        setState(() {
        });
        print('robot ballsInView ${balls}');
      } else if(type == TCPDataType.finishOneFlag) { // 機器人撿球成功上報
        print('robot finishOneFlag');
        DataBaseHelper().insertData(kDataBaseTableName, '');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.darkControllerColor,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Constants.screenWidth(context),
              height: 40,
              margin: EdgeInsets.only(top: 56, left: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        child: Image(
                          image: AssetImage('images/resetmode/tennis_icon.png'),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Container(
                        // margin: EdgeInsets.only(left: 6),
                        child: Constants.mediumWhiteTextWidget(
                            '200', 12, Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: mode == 3
                        ? ButtonSwitchView(
                        leftTitle: 'Retrieve', rightTitle: 'Pause')
                        : ModeSwitchView(areaClick:(index) {
                      if(index == 0) { // A区域
                        setState(() {
                          restModeTotalViewTopMargin = -60;
                        });
                      } else { //B区域
                        setState(() {
                          restModeTotalViewTopMargin = 80;
                        });
                      }
                    },),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    width: 32,
                    height: 16,
                    child: Image(
                      image:
                      AssetImage('images/resetmode/mode_battery_${powerLevels}.png'),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                mode == 2
                    ? Container(
                  margin: EdgeInsets.only(left: 10,right: 10),
                  child: RobotRouteView(),
                  // child: RobotMoveView(),
                )
                    : Container(),
                mode == 3
                    ? Container(
                  child: RemoteControlView(),
                )
                    : Container(
                  margin: EdgeInsets.only(top: 12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage(
                              'images/connect/select_area_line.png'),
                        ),
                        width: Constants.screenWidth(context),
                        height:
                        (Constants.screenWidth(context) - 58 * 2) *
                            (813 / 522) /
                            2 +
                            180,
                      ),
                      mode == 1
                          ? Positioned(
                          left: 16,
                          right: 16,
                          top: restModeTotalViewTopMargin.toDouble(),
                          child: TrainModeTotalView(leftMargin: robotLeftMargin,topMargin: robotTopMargin,robotAngle: 3,ballList: trueBallList,))
                          : Positioned(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 56),
              child: RobotFunctionSwitchView(
                onTapClick: (index) {
                  print('mode=====${index}');
                  modeChange(index);
                  if (index == 1) {
                    // 休息模式
                    RobotManager().setRobotMode(RobotMode.rest);
                    TTDialog.robotEndTaskDialog(context, () async {
                      NavigatorUtil.pop();
                    });
                  } else if (index == 2) {
                    // 训练模式
                    RobotManager().setRobotMode(RobotMode.training);
                    // TTDialog.robotEXceptionDialog(context, () async {
                    //      //   NavigatorUtil.pop();
                    //                });
                  } else if (index == 3) {
                    // 遥控模式
                    RobotManager().setRobotMode(RobotMode.remote);
                    // TTDialog.robotModeAlertDialog(context, () async {
                    //   NavigatorUtil.pop();
                    // });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
