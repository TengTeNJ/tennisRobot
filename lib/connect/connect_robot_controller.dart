import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

class ConnectRobotController extends StatefulWidget {
  const ConnectRobotController({super.key});

  @override
  State<ConnectRobotController> createState() => _ConnectRobotControllerState();
}

class _ConnectRobotControllerState extends State<ConnectRobotController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRect(
         child: Container(
            color: Constants.darkControllerColor,
            child: Column(
               children: [
                  Container(
                      height: 215,
                      width: 278,
                      margin: EdgeInsets.only(top: 167),
                      child: Image(
                        image: AssetImage('images/connect/robot.png'),
                        fit: BoxFit.fill,
                      ),

                  ),
                  Container(
                    width: Constants.screenWidth(context),
                    margin: EdgeInsets.only(left: 16, right: 16 ,top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Constants.boldBaseTextWidget('', 16),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          Constants.connectRobotText,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: Constants.connectTextColor,
                            fontSize: 18,
                            height: 1.8,
                            fontFamily: 'SanFranciscoDisplay',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                   onTap: (){
                     NavigatorUtil.push(Routes.selectMode);
                   } ,
                   child: Container(
                     child: Center(
                       child: Constants.mediumWhiteTextWidget('START', 18 ,Colors.white),
                     ),
                     height: 56,
                     margin: EdgeInsets.only(left: 30, right: 30, top: 65),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Constants.baseStyleColor,
                     ),
                   ), 
                 )
               ],
            ),
         ),
      )
    );
  }
}
