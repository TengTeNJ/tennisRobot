

import 'dart:async';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/models/pickup_ball_model.dart';
import 'package:tennis_robot/models/robot_data_model.dart';
import 'package:tennis_robot/trainmode/mode_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_function_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_move_view.dart';
import 'package:tennis_robot/trainmode/robot_route_view.dart';
import 'package:tennis_robot/trainmode/train_mode_total_view.dart';
import 'package:tennis_robot/utils/dialog.dart';
import 'package:tennis_robot/utils/robot_send_data.dart';
import 'package:tennis_robot/utils/string_util.dart';
import 'package:tennis_robot/utils/toast.dart';
import 'package:tennis_robot/views/button_switch_view.dart';
import 'package:tennis_robot/views/remote_control_view.dart';
import 'package:tennis_robot/utils/navigator_util.dart';
import 'package:tennis_robot/utils/robot_manager.dart';
import 'package:tennis_robot/utils/data_base.dart';
import '../models/ball_model.dart';

enum SelectedArea {
  areaA,
  areaB
}

/// 训练模式
class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  SelectedArea area = SelectedArea.areaA;
  int mode = 0;
  int powerLevels = 5;
  int robotLeftMargin = 25;

  int robotTopMargin = 136;
  double robotAngles = 0.0; //

  List<BallModel> trueBallList = []; // 视野中看到的真实的球
  int restModeTotalViewTopMargin = -60; // 休息模式下整体 topMargin
  int pickUpBalls =0; // 捡球的数量
  void modeChange(int index) {
    setState(() {
      mode = index;
    });
  }

  void getBallData() async {
    final _list  = await DataBaseHelper().getData(kDataBaseTableName);
    List<String> timeArray = [];
    _list.forEach((element){
       timeArray.add(element.time);
    });
    var todayTime = StringUtil.currentTimeString();
    var model = PickupBallModel(pickupBallNumber: pickUpBalls.toString(), time: todayTime);

    if (timeArray.contains(todayTime)) {
      print('数据库有当天的捡球数');
      DataBaseHelper().updateData(kDataBaseTableName, model.toJson(), model.time);
    } else {
      DataBaseHelper().insertData(kDataBaseTableName, model);
    }
  }

  int smoothAngleTransition(int currentAngle, int lastAngle) {
    // const double fullCircle = 360.0;
    // double angleDiff = (currentAngle - lastAngle +pi) % (2 *pi) - pi;
    // if (angleDiff > pi) {
    //   angleDiff -= 2* pi;
    // } else if (angleDiff < -pi) {
    //   angleDiff += 2*pi;
    // }
    if ((currentAngle - lastAngle).abs() > 180) {
      return currentAngle - 360;
    }
    return currentAngle;
  }

  void listenData() {
    // 监听电量
    RobotManager().dataChange = (TCPDataType type) {

      setState(() {
        int power = RobotManager().dataModel.powerValue;
        print('电量 ${power}');
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
      });
      if (type == TCPDataType.deviceInfo) {
        print('robot battery ${RobotManager().dataModel.powerValue}');
      } else if(type == TCPDataType.speed) {
        print('robot speed ${RobotManager().dataModel.speed}');
      } else if(type == TCPDataType.coordinate) { // 机器人坐标
        // 机器人角度
        int robotAngle = RobotManager().dataModel.angle;
        // 机器人X坐标
        int xPoint = RobotManager().dataModel.xPoint;
        // 机器人Y坐标
        int yPoint = RobotManager().dataModel.yPoint;
        xPoint = (1097/2).toInt();
        yPoint = 640;
        robotAngle = 130;
        TTToast.showToast('X:${xPoint}  Y:${yPoint} R:${robotAngle}');

        // 虚拟网球场高度
        var virualHeight =  (Constants.screenWidth(context) - 58 * 2) *
            (813 / 522) /
            2 +
            180;
        var virualWidth = 522 * virualHeight / 813;
        var screenHeight = Constants.screenHeight(context);
        // 真实球场宽 10.97   高23.77
        // 机器人坐标转换
        setState(() {
          robotLeftMargin = (xPoint / 100 / 10.97 * virualWidth).toInt() + 20;
          if (xPoint == 0) {
            robotLeftMargin = 25;
          }
          robotTopMargin = (yPoint / 100 / (23.77 / 2) * virualHeight/2 ).toInt() + 136;
          if (area == SelectedArea.areaB){
            robotTopMargin  = robotTopMargin - 140;
          }
          print('robotLeftMargin-=-=${robotLeftMargin}');
          print('robotTopMargin====${robotTopMargin}');

        });
        robotAngles = -robotAngle / 360.0; // 角度调试
        print('robot coordinate ${xPoint}  ${yPoint} ${robotAngle}');
      } else if(type == TCPDataType.ballsInView) { // 视野中看到的球
        List balls = RobotManager().dataModel.inViewBallList;
        print('inViewBallList ${balls}');

        trueBallList.clear();
        trueBallList.addAll(balls as Iterable<BallModel>);
        setState(() {
        });
        print('robot ballsInView ${balls}');
      } else if(type == TCPDataType.finishOneFlag) { // 機器人撿球成功上報
        print('robot finishOneFlag');
        pickUpBalls += 1;
        getBallData();// 数据库处理
      } else if(type == TCPDataType.errorInfo) { // 异常信息
        var desc = '';
        var status = RobotManager().dataModel.errorStatu;
        if (status == 1) {  // 1 收球轮异常故障
          desc = 'Abnormal malfunction of the ball receiving wheel';
        } else if(status == 2) { //行走轮异常故障
          desc = 'Abnormal malfunction of the walking wheel';
        } else if(status == 3) { //摄像头异常故障
          desc = 'Camera malfunction';
        } else if (status == 4) { // 雷达异常故障
          desc = 'Radar abnormal malfunction';
        }
        TTDialog.robotEXceptionDialog(context,desc, () async {
          NavigatorUtil.pop();
        });
      } else if(type == TCPDataType.warnInfo) { // 告警信息
        print('robot warnInfo');
      }
    };
  }

  @override
  void initState() {
    super.initState();
    print('66666${RobotManager().manualFetch(ManualFetchType.device)}');
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
                            '${pickUpBalls}', 12, Colors.white),
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
                          robotTopMargin = 136;
                          area = SelectedArea.areaA;

                        });
                      } else { //B区域
                        setState(() {
                          restModeTotalViewTopMargin = 80;
                          robotTopMargin = 14;
                          area = SelectedArea.areaB;

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
                  margin: EdgeInsets.only(left: 10,right: 10,top: 20),
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
                          child: TrainModeTotalView(leftMargin: robotLeftMargin,topMargin: robotTopMargin,robotAngle: robotAngles,ballList: trueBallList,))
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
                    print('屏幕宽${Constants.screenWidth(context)}');
                    // 休息模式
                    RobotManager().setRobotMode(RobotMode.rest);
                    var angle = smoothAngleTransition(347, 10);
                    print('6666-=-==${angle}');
                    listenData();
                  } else if (index == 2) {
                    // 训练模式
                    RobotManager().setRobotMode(RobotMode.training);
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
