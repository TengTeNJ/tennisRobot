import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/trainmode/mode_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_function_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_move_view.dart';
import 'package:tennis_robot/trainmode/robot_route_view.dart';
import 'package:tennis_robot/trainmode/train_mode_total_view.dart';
import 'package:tennis_robot/utils/dialog.dart';
import 'package:tennis_robot/views/button_switch_view.dart';
import 'package:tennis_robot/views/remote_control_view.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

/// 训练模式
class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  int mode = 0;

  void modeChange(int index) {
    setState(() {
      mode = index;
    });
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
                        : ModeSwitchView(),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    width: 32,
                    height: 16,
                    child: Image(
                      image:
                          AssetImage('images/resetmode/mode_battery_icon.png'),
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
                          top: 100,
                          child: TrainModeTotalView())
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
                  // if (index == 1) {
                  //   TTDialog.robotEndTaskDialog(context, () async {
                  //     NavigatorUtil.pop();
                  //   });
                  // } else if (index == 2) {
                  //   TTDialog.robotEXceptionDialog(context, () async {
                  //     NavigatorUtil.pop();
                  //   });
                  // } else if (index == 3) {
                  //   TTDialog.robotModeAlertDialog(context, () async {
                  //     NavigatorUtil.pop();
                  //   });
                  // }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
