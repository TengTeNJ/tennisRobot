import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

enum KeyName {
  None,
  leftAxisX,
  leftAxisY,
  rightAxisX,
  rightAxisY,
  lS,
  rS,
  triggerLeft,
  triggerRight,
  buttonUpDown,
  buttonLeftRight,
  buttonA,
  buttonB,
  buttonX,
  buttonY,
  buttonLB,
  buttonRB,
}

class JoyStickEvent {
  late KeyName keyName;
  bool reverse = false; //是否反转(反转填-1)Q
  double maxValue = 32767;
  double minValue = -32767;
  double val = 0;

  set value(double val) {
    if (val > maxValue) {
      val = maxValue;
    } else if (val < minValue) {
      val = minValue;
    }
    if (reverse) {
      val = -val;
    }
  }

  double get value {
    //数值归一化-1到1
    var normalizedValue = (val - minValue) / (maxValue - minValue) * 2 - 1;
    return normalizedValue;
  }

  JoyStickEvent(this.keyName,
      {this.reverse = false, this.maxValue = 32767, this.minValue = -32767});
}

enum RobotType {
  ROS2Default,
  ROS1,
  TurtleBot3,
  TurtleBot4,
  Jackal,
}

extension RobotTypeExtension on RobotType {
  String get displayName {
    switch (this) {
      case RobotType.ROS2Default:
        return "ROS2 默认";
      case RobotType.ROS1:
        return "ROS1";
      case RobotType.TurtleBot3:
        return "TurtleBot3";
      case RobotType.TurtleBot4:
        return "TurtleBot4";
      case RobotType.Jackal:
        return "Jackal";
    }
  }

  String get value {
    switch (this) {
      case RobotType.ROS2Default:
        return "2";
      case RobotType.ROS1:
        return "1";
      case RobotType.TurtleBot3:
        return "3";
      case RobotType.TurtleBot4:
        return "4";
      case RobotType.Jackal:
        return "5";
    }
  }
}

class Setting {
  late SharedPreferences prefs;

// 定义一个映射关系，将Dart中的类名映射到JavaScript中的类名
  Map<String, JoyStickEvent> axisMapping = {
    "AXIS_X": JoyStickEvent(KeyName.leftAxisX),
    "AXIS_Y": JoyStickEvent(KeyName.leftAxisY),
    "AXIS_Z": JoyStickEvent(KeyName.rightAxisX),
    "AXIS_RZ": JoyStickEvent(KeyName.rightAxisY),
    "triggerRight": JoyStickEvent(KeyName.triggerRight),
    "triggerLeft": JoyStickEvent(KeyName.triggerLeft),
    "buttonLeftRight": JoyStickEvent(KeyName.buttonLeftRight),
    "buttonUpDown": JoyStickEvent(KeyName.buttonUpDown),
  };
  Map<String, JoyStickEvent> buttonMapping = {
    "KEYCODE_BUTTON_A":
        JoyStickEvent(KeyName.buttonA, maxValue: 1, minValue: 0, reverse: true),
    "KEYCODE_BUTTON_B":
        JoyStickEvent(KeyName.buttonB, maxValue: 1, minValue: 0, reverse: true),
    "KEYCODE_BUTTON_X":
        JoyStickEvent(KeyName.buttonX, maxValue: 1, minValue: 0, reverse: true),
    "KEYCODE_BUTTON_Y":
        JoyStickEvent(KeyName.buttonY, maxValue: 1, minValue: 0, reverse: true),
    "KEYCODE_BUTTON_L1": JoyStickEvent(KeyName.buttonLB,
        maxValue: 1, minValue: 0, reverse: true),
    "KEYCODE_BUTTON_R1": JoyStickEvent(KeyName.buttonRB,
        maxValue: 1, minValue: 0, reverse: true),
  };

  Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();

    // 获取应用版本
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    if (!prefs.containsKey("init") ||
        !prefs.containsKey("version") ||
        prefs.getString("version") != currentVersion) {
      setDefaultCfgRos2();
      prefs.setString("version", currentVersion);
    }

    // 从配置中加载手柄映射
    await _loadGamepadMapping();

    return true;
  }

  Future<void> _loadGamepadMapping() async {
    final mappingStr = prefs.getString('gamepadMapping');
    print(mappingStr);
    if (mappingStr != null) {
      try {
        final mapping = jsonDecode(mappingStr);

        // 清空现有映射
        axisMapping.clear();
        buttonMapping.clear();

        // 加载 axisMapping
        if (mapping['axisMapping'] != null) {
          (mapping['axisMapping'] as Map<String, dynamic>)
              .forEach((key, value) {
            final keyName = _parseKeyName(value['keyName']);
            axisMapping[key] = JoyStickEvent(
              keyName,
              maxValue: value['maxValue'] ?? 32767,
              minValue: value['minValue'] ?? -32767,
              reverse: value['reverse'] ?? false,
            );
          });
        }

        // 加载 buttonMapping
        if (mapping['buttonMapping'] != null) {
          (mapping['buttonMapping'] as Map<String, dynamic>)
              .forEach((key, value) {
            final keyName = _parseKeyName(value['keyName']);
            buttonMapping[key] = JoyStickEvent(
              keyName,
              maxValue: value['maxValue'] ?? 1,
              minValue: value['minValue'] ?? 0,
              reverse: value['reverse'] ?? true,
            );
          });
        }
      } catch (e) {
        print('Error loading gamepad mapping: $e');
        // 如果加载失败，使用默认映射
        resetGamepadMapping();
      }
    }
  }

  KeyName _parseKeyName(String keyNameStr) {
    // 移除 'KeyName.' 前缀
    final enumStr = keyNameStr.replaceAll('KeyName.', '');
    return KeyName.values.firstWhere(
      (e) => e.toString() == 'KeyName.$enumStr',
      orElse: () => KeyName.None,
    );
  }

  Future<void> saveGamepadMapping() async {
    // 将默认映射保存到配置中
    final mapping = {
      'axisMapping': axisMapping.map((key, value) => MapEntry(key, {
            'keyName': value.keyName.toString(),
            'maxValue': value.maxValue,
            'minValue': value.minValue,
            'reverse': value.reverse,
          })),
      'buttonMapping': buttonMapping.map((key, value) => MapEntry(key, {
            'keyName': value.keyName.toString(),
            'maxValue': value.maxValue,
            'minValue': value.minValue,
            'reverse': value.reverse,
          })),
    };
    print(jsonEncode(mapping));
    await prefs.setString('gamepadMapping', jsonEncode(mapping));
  }

  Future<void> resetGamepadMapping() async {
    axisMapping.clear();
    buttonMapping.clear();

    // 恢复默认的轴映射
    axisMapping.addAll({
      "AXIS_X": JoyStickEvent(KeyName.leftAxisX),
      "AXIS_Y": JoyStickEvent(KeyName.leftAxisY),
      "AXIS_Z": JoyStickEvent(KeyName.rightAxisX),
      "AXIS_RZ": JoyStickEvent(KeyName.rightAxisY),
      "triggerRight": JoyStickEvent(KeyName.triggerRight),
      "triggerLeft": JoyStickEvent(KeyName.triggerLeft),
      "buttonLeftRight": JoyStickEvent(KeyName.buttonLeftRight),
      "buttonUpDown": JoyStickEvent(KeyName.buttonUpDown),
    });

    // 恢复默认的按钮映射
    buttonMapping.addAll({
      "KEYCODE_BUTTON_A": JoyStickEvent(KeyName.buttonA,
          maxValue: 1, minValue: 0, reverse: true),
      "KEYCODE_BUTTON_B": JoyStickEvent(KeyName.buttonB,
          maxValue: 1, minValue: 0, reverse: true),
      "KEYCODE_BUTTON_X": JoyStickEvent(KeyName.buttonX,
          maxValue: 1, minValue: 0, reverse: true),
      "KEYCODE_BUTTON_Y": JoyStickEvent(KeyName.buttonY,
          maxValue: 1, minValue: 0, reverse: true),
      "KEYCODE_BUTTON_L1": JoyStickEvent(KeyName.buttonLB,
          maxValue: 1, minValue: 0, reverse: true),
      "KEYCODE_BUTTON_R1": JoyStickEvent(KeyName.buttonRB,
          maxValue: 1, minValue: 0, reverse: true),
    });

    // 将默认映射保存到配置中
    final mapping = {
      'axisMapping': axisMapping.map((key, value) => MapEntry(key, {
            'keyName': value.keyName.toString(),
            'maxValue': value.maxValue,
            'minValue': value.minValue,
            'reverse': value.reverse,
          })),
      'buttonMapping': buttonMapping.map((key, value) => MapEntry(key, {
            'keyName': value.keyName.toString(),
            'maxValue': value.maxValue,
            'minValue': value.minValue,
            'reverse': value.reverse,
          })),
    };

    await prefs.setString('gamepadMapping', jsonEncode(mapping));
  }

  void setDefaultCfgRos2Jackal() {
    prefs.setString('mapTopic', "map");
    prefs.setString('laserTopic', "/sensors/lidar_0/scan");
    prefs.setString('globalPathTopic', "/plan");
    prefs.setString('localPathTopic', "/plan");
    prefs.setString('relocTopic', "/initialpose");
    prefs.setString('navGoalTopic', "/goal_pose");
    prefs.setString('OdometryTopic', "/platform/odom/filtered");
    prefs.setString('SpeedCtrlTopic', "/cmd_vel");
    prefs.setString('BatteryTopic', "/battery_status");
    prefs.setString('MaxVx', "0.1");
    prefs.setString('MaxVy', "0.1");
    prefs.setString('MaxVw', "0.3");
    prefs.setString('mapFrameName', "map");
    prefs.setString('baseLinkFrameName', "base_link");
    prefs.setString('imagePort', "8080");
    prefs.setString('imageTopic', "/camera/image_raw");
    prefs.setDouble('imageWidth', 640);
    prefs.setDouble('imageHeight', 480);
  }

  void setDefaultCfgRos2TB4() {
    prefs.setString('mapTopic', "map");
    prefs.setString('laserTopic', "scan");
    prefs.setString('globalPathTopic', "/plan");
    prefs.setString('localPathTopic', "/local_plan");
    prefs.setString('relocTopic', "/initialpose");
    prefs.setString('navGoalTopic', "/goal_pose");
    prefs.setString('OdometryTopic', "/odom");
    prefs.setString('SpeedCtrlTopic', "/cmd_vel");
    prefs.setString('BatteryTopic', "/battery_status");
    prefs.setString('MaxVx', "0.1");
    prefs.setString('MaxVy', "0.1");
    prefs.setString('MaxVw', "0.3");
    prefs.setString('mapFrameName', "map");
    prefs.setString('baseLinkFrameName', "base_link");
    prefs.setString('imagePort', "8080");
    prefs.setString('imageTopic', "/camera/image_raw");
    prefs.setDouble('imageWidth', 640);
    prefs.setDouble('imageHeight', 480);
  }

  void setDefaultCfgRos2TB3() {
    prefs.setString('mapTopic', "map");
    prefs.setString('laserTopic', "scan");
    prefs.setString('globalPathTopic', "/plan");
    prefs.setString('localPathTopic', "/local_plan");
    prefs.setString('relocTopic', "/initialpose");
    prefs.setString('navGoalTopic', "/goal_pose");
    prefs.setString('OdometryTopic', "/odom");
    prefs.setString('SpeedCtrlTopic', "/cmd_vel");
    prefs.setString('BatteryTopic', "/battery_status");
    prefs.setString('MaxVx', "0.1");
    prefs.setString('MaxVy', "0.1");
    prefs.setString('MaxVw', "0.3");
    prefs.setString('mapFrameName', "map");
    prefs.setString('baseLinkFrameName', "base_link");
    prefs.setString('imagePort', "8080");
    prefs.setString('imageTopic', "/camera/image_raw");
    prefs.setDouble('imageWidth', 640);
    prefs.setDouble('imageHeight', 480);
  }

  void setDefaultCfgRos2() {
    // TODO: 修改配置默认话题
    prefs.setString('mapTopic', "/map");
    prefs.setString('laserTopic', "/scan");
    prefs.setString('globalPathTopic', "/plan");
    prefs.setString('localPathTopic', "/local_plan");
    prefs.setString('relocTopic', "/initialpose");
    prefs.setString('navGoalTopic', "/goal_pose");
    prefs.setString('OdometryTopic', "/wheel/odometry");
    prefs.setString('SpeedCtrlTopic', "/cmd_vel");
    prefs.setString('BatteryTopic', "/battery_status");
    // TODO: 修改配置默认速速
    prefs.setString('MaxVx', "0.8");
    prefs.setString('MaxVy', "0.5");
    prefs.setString('MaxVw', "0.5");
    prefs.setString('mapFrameName', "map");
    prefs.setString('baseLinkFrameName', "base_footprint");
    prefs.setString('imagePort', "8080");
    prefs.setString('imageTopic', "/camera/image_raw");
    prefs.setDouble('imageWidth', 640);
    prefs.setDouble('imageHeight', 480);
  }

  void setDefaultCfgRos1() {
    prefs.setString('mapTopic', "map");
    prefs.setString('laserTopic', "scan");
    prefs.setString('globalPathTopic', "/move_base/DWAPlannerROS/global_plan");
    prefs.setString('localPathTopic', "/move_base/DWAPlannerROS/local_plan");
    prefs.setString('relocTopic', "/initialpose");
    prefs.setString('navGoalTopic', "move_base_simple/goal");
    prefs.setString('OdometryTopic', "/odom");
    prefs.setString('SpeedCtrlTopic', "/cmd_vel");
    prefs.setString('BatteryTopic', "/battery_status");
    prefs.setString('MaxVx', "0.1");
    prefs.setString('MaxVy', "0.1");
    prefs.setString('MaxVw', "0.3");
    prefs.setString('mapFrameName', "map");
    prefs.setString('baseLinkFrameName', "base_link");
    prefs.setString('imagePort', "8080");
    prefs.setString('imageTopic', "/camera/rgb/image_raw");
    prefs.setDouble('imageWidth', 640);
    prefs.setDouble('imageHeight', 480);
  }

  SharedPreferences get config {
    return prefs;
  }

  double get imageWidth {
    return prefs.getDouble("imageWidth") ?? 640;
  }

  double get imageHeight {
    return prefs.getDouble("imageHeight") ?? 480;
  }

  String get robotIp {
    return prefs.getString("robotIp") ?? "127.0.0.1";
  }

  String get imagePort {
    return prefs.getString("imagePort") ?? "8080";
  }

  String get imageTopic {
    return prefs.getString("imageTopic") ?? "/camera/rgb/image_raw";
  }

  String get robotPort {
    return prefs.getString("robotPort") ?? "9090";
  }

  void setMapTopic(String topic) {
    prefs.setString('mapTopic', topic);
  }

  String get mapTopic {
    return prefs.getString("mapTopic") ?? "map";
  }

  void setLaserTopic(String topic) {
    prefs.setString('laserTopic', topic);
  }

  String get laserTopic {
    return prefs.getString("laserTopic") ?? "scan";
  }

  void setGloalPathTopic(String topic) {
    prefs.setString('globalPathTopic', topic);
  }

  String get globalPathTopic {
    return prefs.getString("globalPathTopic") ?? "plan";
  }

  void setLocalPathTopic(String topic) {
    prefs.setString('localPathTopic', topic);
  }

  String get localPathTopic {
    return prefs.getString("localPathTopic") ?? "/local_plan";
  }

  void setRelocTopic(String topic) {
    prefs.setString('relocTopic', topic);
  }

  String get relocTopic {
    return prefs.getString("relocTopic") ?? "/initialpose";
  }

  String get mapFrameName {
    return prefs.getString("mapFrameName") ?? "map";
  }

  String get baseLinkFrameName {
    return prefs.getString("baseLinkFrameName") ?? "base_link";
  }

  String get navGoalTopic {
    return prefs.getString("navGoalTopic") ?? "/goal_pose";
  }

  void setNavGoalTopic(String topic) {
    prefs.setString('navGoalTopic', topic);
  }

  String get batteryTopic {
    return prefs.getString("BatteryTopic") ?? "/battery_status";
  }

  void setBatteryTopic(String topic) {
    prefs.setString('BatteryTopic', topic);
  }

  String getConfig(String key) {
    return prefs.getString(key) ?? "";
  }

  String get odomTopic {
    return prefs.getString("OdometryTopic") ?? "/wheel/odometry";
  }

  void setOdomTopic(String topic) {
    prefs.setString('OdometryTopic', topic);
  }

  // 添加速度控制相关的方法
  void setSpeedCtrlTopic(String topic) {
    prefs.setString('SpeedCtrlTopic', topic);
  }

  String get speedCtrlTopic {
    return prefs.getString("SpeedCtrlTopic") ?? "/cmd_vel";
  }

  // 添加最大速度设置方法
  void setMaxVx(String value) {
    prefs.setString('MaxVx', value);
  }

  void setMaxVy(String value) {
    prefs.setString('MaxVy', value);
  }

  void setMaxVw(String value) {
    prefs.setString('MaxVw', value);
  }

  // 添加最大速度获取方法
  double get maxVx {
    return double.parse(prefs.getString("MaxVx") ?? "0.1");
  }

  double get maxVy {
    return double.parse(prefs.getString("MaxVy") ?? "0.1");
  }

  double get maxVw {
    return double.parse(prefs.getString("MaxVw") ?? "0.3");
  }

  // 添加图像设置方法
  void setImagePort(String port) {
    prefs.setString('imagePort', port);
  }

  void setImageTopic(String topic) {
    prefs.setString('imageTopic', topic);
  }

  void setImageWidth(double width) {
    prefs.setDouble('imageWidth', width);
  }

  void setImageHeight(double height) {
    prefs.setDouble('imageHeight', height);
  }

  // 添加框架名称设置方法
  void setMapFrameName(String name) {
    prefs.setString('mapFrameName', name);
  }

  void setBaseLinkFrameName(String name) {
    prefs.setString('baseLinkFrameName', name);
  }

  // 添加通用配置设置方法
  void setConfig(String key, String value) {
    prefs.setString(key, value);
  }

  // 基本设置相关方法
  void setRobotIp(String ip) {
    prefs.setString('robotIp', ip);
  }

  void setRobotPort(String port) {
    prefs.setString('robotPort', port);
  }

  /// 建图的名字
  void setRobotMapName(String mapName) {
    prefs.setString('robotMapName', mapName);
  }

  String get RobotMapName {
    return prefs.getString("robotMapName") ?? "";
  }

  /// 建图的地址
  void setRobotMapLocation(String mapLocation) {
    prefs.setString('robotMapLocation', mapLocation);
  }

  String get RobotMapLocation {
    return prefs.getString("robotMapLocation") ?? "";
  }

  // 地图相关方法

  void setMapMetadataTopic(String topic) {
    prefs.setString('mapMetadataTopic', topic);
  }

  // 定位相关方法

  void setInitPoseTopic(String topic) {
    prefs.setString('initPoseTopic', topic);
  }

  void setAmclPoseTopic(String topic) {
    prefs.setString('amclPoseTopic', topic);
  }

  // 导航相关方法
  void setMoveBaseTopic(String topic) {
    prefs.setString('moveBaseTopic', topic);
  }

  void setCmdVelTopic(String topic) {
    prefs.setString('cmdVelTopic', topic);
  }

  void setGlobalPlanTopic(String topic) {
    prefs.setString('globalPlanTopic', topic);
  }

  void setLocalPlanTopic(String topic) {
    prefs.setString('localPlanTopic', topic);
  }

  void setGlobalCostmapTopic(String topic) {
    prefs.setString('globalCostmapTopic', topic);
  }

  void setLocalCostmapTopic(String topic) {
    prefs.setString('localCostmapTopic', topic);
  }

  void setGlobalPathTopic(String topic) {
    prefs.setString('globalPathTopic', topic);
  }

  // 状态监控相关方法
  void setRobotStatusTopic(String topic) {
    prefs.setString('robotStatusTopic', topic);
  }

  void setJointStatesTopic(String topic) {
    prefs.setString('jointStatesTopic', topic);
  }

  // 获取各个配置的默认值方法
  Map<String, String> getDefaultValues() {
    return {
      'robotIp': '192.168.1.100',
      'robotPort': '9090',
      'mapTopic': '/map',
      'mapMetadataTopic': '/map_metadata',
      'laserTopic': '/scan',
      'initPoseTopic': '/initialpose',
      'amclPoseTopic': '/amcl_pose',
      'odomTopic': '/odom',
      'moveBaseTopic': '/move_base',
      'cmdVelTopic': '/cmd_vel',
      'globalPlanTopic': '/move_base/GlobalPlanner/plan',
      'localPlanTopic': '/move_base/local_plan',
      'globalCostmapTopic': '/move_base/global_costmap/costmap',
      'localCostmapTopic': '/move_base/local_costmap/costmap',
      'globalPathTopic': '/move_base/NavfnROS/plan',
      'localPathTopic': '/move_base/DWAPlannerROS/local_plan',
      'robotStatusTopic': '/robot_status',
      'batteryTopic': '/battery_state',
      'jointStatesTopic': '/joint_states'
    };
  }
}

Setting globalSetting = Setting();

// 初始化全局配置
Future<bool> initGlobalSetting() async {
  return globalSetting.init();
}
