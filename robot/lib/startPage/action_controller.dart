import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/startPage/action_data_list_view.dart';
import 'package:tennis_robot/startPage/robot_battery_progress_view.dart';

class ActionController extends StatefulWidget {
  const ActionController({super.key});

  @override
  State<ActionController> createState() => _ActionControllerState();
}

class _ActionControllerState extends State<ActionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.darkControllerColor,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Container(
          children: [
            Container(
              margin: EdgeInsets.only(top: 16, left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Constants.actionRegularGreyTextWidget('Robot', 22),
                  GestureDetector(
                      child:Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(top: 0,right: 16),
                        child: Stack(
                          children: [
                            Image(
                                image: AssetImage('images/connect/wifi_connect.png')),
                            Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ))
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 65,top: 24),
              child: Image(
                width: 277,
                height: 215,
                image: AssetImage('images/connect/home_robot.png'),
              ),
            ),
            Container(
              width: Constants.screenWidth(context),
              height: 60,
              margin: EdgeInsets.only(top: 30),
              child: RobotBatteryProgressView(),
            ),
            Container(
              margin: EdgeInsets.only(top: 18),
              width: Constants.screenWidth(context),
              child: ActionDataListView(),
            ),
          ],
        ),
      ),
    );
  }

}
