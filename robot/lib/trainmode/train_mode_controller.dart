import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/trainmode/mode_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_function_switch_view.dart';
import 'package:tennis_robot/trainmode/robot_move_view.dart';
import 'package:tennis_robot/trainmode/robot_route_view.dart';
import 'package:tennis_robot/trainmode/train_mode_total_view.dart';

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
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Constants.screenWidth(context),
            height: 40,
            margin: EdgeInsets.only(top: 67, left: 20),
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
                  child: ModeSwitchView(),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  width: 32,
                  height: 16,
                  child: Image(
                    image: AssetImage('images/resetmode/mode_battery_icon.png'),
                  ),
                ),
              ],
            ),
          ),
          mode == 2
              ? Container(
                  margin: EdgeInsets.only(top: 18),
                  child: RobotRouteView(),
                  // child: RobotMoveView(),
                )
              : Container(
                  margin: EdgeInsets.only(top: 18),
                  child: SizedBox(
                    height: 60,
                  ),
                ),

          Container(
            margin: EdgeInsets.only(top: 10),
            // child: Image(image: AssetImage('images/connect/select_area_line.png'),
            // width: Constants.screenWidth(context),
            // height: (Constants.screenWidth(context) -58*2) * (813 / 522) / 2 + 180,
            // ),
            //

            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: Image(
                    image: AssetImage('images/connect/select_area_line.png'),
                  ),
                  width: Constants.screenWidth(context),
                  height: (Constants.screenWidth(context) - 58 * 2) *
                          (813 / 522) /
                          2 +
                      180,
                ),

                mode == 1 ?
                Positioned(
                    left: 24,
                    top: 100,
                    child: TrainModeTotalView()
                )
                    : Positioned(child: Container(),),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 70),
            child: RobotFunctionSwitchView(
              resetModeClick: () {
                modeChange(1);
              },
              trainModeClick: () {
                modeChange(2);
              },
            ),
          ),
        ],
      ),
    );
  }
}
