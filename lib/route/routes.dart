import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tennis_robot/choosearea/choose_area_controller.dart';
import 'package:tennis_robot/connect/connect_robot_controller.dart';
import 'package:tennis_robot/home/home_page_controller.dart';
import 'package:tennis_robot/root_page.dart';
import 'package:tennis_robot/selectmode/select_mode_controller.dart';
import 'package:tennis_robot/trainmode/train_mode_controller.dart';

class Routes {
  static const String home = '/'; // 主页
  static const String selectMode = 'selectMode'; // 选择模式界面
  static const String connect = 'connect'; // 链接机器人界面
  static const String selectArea = 'selectArea'; // 选择区域界面
  static const String trainMode = 'trainMode'; // 训练模式

  static RouteFactory onGenerateRoute = (settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => RootPageController());
      case selectMode:
        return MaterialPageRoute(builder: (_) => SelectModeController());
      case connect:
        return MaterialPageRoute(builder: (_) => ConnectRobotController());
      case selectArea:
        return MaterialPageRoute(builder: (_) => ChooseAreaController());
      case trainMode:
        return MaterialPageRoute(builder: (_) => TrainModeController());
    }
  };
}