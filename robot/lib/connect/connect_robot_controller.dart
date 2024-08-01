import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';
import 'package:tennis_robot/utils/robot_manager.dart';

class ConnectRobotController extends StatefulWidget {
  const ConnectRobotController({super.key});

  @override
  State<ConnectRobotController> createState() => _ConnectRobotControllerState();
}

class _ConnectRobotControllerState extends State<ConnectRobotController> {
  bool isConnected = true; // 是否连接上WiFi

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
                  // color: Colors.red,
                  width: Constants.screenWidth(context),
                  margin: EdgeInsets.only(left: 44, right: 44, top: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Constants.boldBaseTextWidget('', 16),
                      SizedBox(
                        height: 10,
                      ),

                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: Constants.connectRobotText,
                              style: TextStyle(
                                color: Constants.connectTextColor,
                                fontSize: 18,
                                height: 1.8,
                                fontFamily: 'SanFranciscoDisplay',
                                fontWeight: FontWeight.w500,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '   "Potent"',
                                  style: TextStyle(
                                    fontFamily: 'SanFranciscoDisplay',
                                    fontSize: 18,
                                    color: Color.fromRGBO(233, 86, 21, 1),
                                    height: 1.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ])),
                      SizedBox(height: 50),
                      Text(
                        "Current Wi-Fi Network",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.connectTextColor,
                          fontSize: 18,
                          height: 1.5,
                          fontFamily: 'SanFranciscoDisplay',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Potent Robot",
                        textAlign: TextAlign.center,
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
                  onTap: () {
                    RobotManager().startTCPConnect();
                    // 在需要用到的页面进行数据监听 格式如下，根据不同的TCPDataType类型和自己的需求进行页面刷新
                    RobotManager().dataChange = (TCPDataType type) {
                      if (type == TCPDataType.speed) {
                        print('speed123 ${RobotManager().dataModel.speed}');
                      } else if(type == TCPDataType.deviceInfo) {
                        print('deviceInfo123 ${RobotManager().dataModel.speed}');
                      }
                    };
                    NavigatorUtil.push(Routes.selectMode);
                  },
                  child: Container(
                    child: Center(
                      child: Constants.mediumWhiteTextWidget(
                          'Add Robot', 20,isConnected ? Colors.white : Constants.grayTextColor),
                    ),
                    height: 72,
                    margin: EdgeInsets.only(left: 44, right: 44, top: 65),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isConnected ? Constants.selectedModelOrangeBgColor : Constants.selectModelBgColor ,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
