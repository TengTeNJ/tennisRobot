import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';

class RobotBatteryProgressView extends StatefulWidget {
  const RobotBatteryProgressView({super.key});

  @override
  State<RobotBatteryProgressView> createState() => _RobotBatteryProgressViewState();
}

class _RobotBatteryProgressViewState extends State<RobotBatteryProgressView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 160,
        padding: EdgeInsets.only(left: 70,right: 70),
        alignment: Alignment.center,
        child: Column(
           children: [
             Container(
               child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                     Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          color: Constants.baseTextGrayBgColor,
                        ),
                       width: 240,
                       height: 34,
                     ),
                     Container(
                     decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Constants.selectedModelBgColor,
                            ),
                            width: 180,
                            height: 30,
                     ),
                     Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 86),
                      // height: 34,
                      child: Row(
                        children: [
                          Image.asset('images/connect/battery_icon.png',

                            width: 10,
                            height: 15,
                          ),
                           Container(
                               margin: EdgeInsets.only(left: 8),
                               child: Row(
                                  children: [
                                    Constants.mediumWhiteTextWidget('70', 24, Colors.white),
                                    Constants.mediumWhiteTextWidget('%', 16, Colors.white)
                                  ],
                               ),

                           ),
                        ],
                      ),
                    ),
                  ],
               ),
             ),

             Container(
               margin: EdgeInsets.only(top: 6),
               width:188,
               height: 20,
               child: Constants.mediumWhiteTextWidget('100 mins left', 16, Constants.grayTextColor),
             ),
           ],
        ),
    );
  }
}
