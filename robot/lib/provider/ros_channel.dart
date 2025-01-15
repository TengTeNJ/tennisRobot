import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tennis_robot/basic/RobotPose.dart';
import 'package:tennis_robot/basic/robot_path.dart';
import 'package:tennis_robot/basic/tf2_dart.dart';
import 'package:tennis_robot/basic/transform.dart';
import 'package:tennis_robot/global/setting.dart';
import 'package:roslibdart/roslibdart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import "package:tennis_robot/basic/occupancy_map.dart";
import 'package:tennis_robot/basic/tf.dart';
import 'package:tennis_robot/basic/laser_scan.dart';
import "package:tennis_robot/basic/math.dart";
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:tennis_robot/global/setting.dart';
import 'package:image/image.dart' as img;

class LaserData {
  RobotPose robotPose;
  List<Offset> laserPoseBaseLink;
  LaserData({required this.robotPose, required this.laserPoseBaseLink});
}

class RobotSpeed {
  double vx;
  double vy;
  double vw;
  RobotSpeed({required this.vx, required this.vy, required this.vw});
}

class RosChannel extends ChangeNotifier {
  late Ros ros;
  late Topic mapChannel_;
  late Topic tfChannel_;
  late Topic tfStaticChannel_;
  late Topic laserChannel_;
  late Topic localPathChannel_;
  late Topic globalPathChannel_;
  late Topic relocChannel_;
  late Topic navGoalChannel_;
  late Topic speedCtrlChannel_;
  late Topic odomChannel_;
  late Topic batteryChannel_;
  late Topic imageTopic_;
  Timer? cmdVelTimer;

  bool manualCtrlMode_ = false;
  ValueNotifier<double> battery_ = ValueNotifier(0);
  ValueNotifier<Uint8List> imageData = ValueNotifier(Uint8List(0));
  RobotSpeed cmdVel_ = RobotSpeed(vx: 0, vy: 0, vw: 0);
  double vxLeft_ = 0;
  ValueNotifier<RobotSpeed> robotSpeed_ =
      ValueNotifier(RobotSpeed(vx: 0, vy: 0, vw: 0));
  String url_ = "";
  TF2Dart tf_ = TF2Dart();
  ValueNotifier<OccupancyMap> map_ =
      ValueNotifier<OccupancyMap>(OccupancyMap());
  Status rosConnectState_ = Status.none;
  ValueNotifier<RobotPose> currRobotPose_ = ValueNotifier(RobotPose.zero());
  ValueNotifier<RobotPose> robotPoseScene = ValueNotifier(RobotPose.zero());
  ValueNotifier<List<Offset>> laserPoint_ = ValueNotifier([]);
  ValueNotifier<List<Offset>> localPath = ValueNotifier([]);
  ValueNotifier<List<Offset>> globalPath = ValueNotifier([]);
  ValueNotifier<LaserData> laserPointData = ValueNotifier(
      LaserData(robotPose: RobotPose(0, 0, 0), laserPoseBaseLink: []));

  RosChannel() {
    //启动定时器 获取机器人实时坐标
    globalSetting.init().then((success) {
      if (success) {
        connect("ws://${globalSetting.robotIp}:${globalSetting.robotPort}");
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
          try {
            currRobotPose_.value = tf_.lookUpForTransform(
                globalSetting.mapFrameName, globalSetting.baseLinkFrameName);
            Offset poseScene = map_.value
                .xy2idx(Offset(currRobotPose_.value.x, currRobotPose_.value.y));
            robotPoseScene.value = RobotPose(
                poseScene.dx, poseScene.dy, currRobotPose_.value.theta);
          } catch (e) {
            // TODO:暂时注释掉错误信息
          //  print("get robot pose error:${e}");
          }
        });
      }
    });
  }

  RobotPose get robotPoseMap {
    return currRobotPose_.value;
  }

  Future<bool> connect(String url) async {
    rosConnectState_ = Status.none;
    ros = Ros(url: url);

    ros.statusStream.listen(
      (Status data) {
        print("connect state: $data");
        rosConnectState_ = data;
      },
      onError: (error) {
        print('Error occurred: $error'); // 打印错误信息
      },
      onDone: () {
        print('Stream closed'); // 打印流关闭信息
      },
      cancelOnError: false, // 是否在遇到错误时取消订阅，默认为false);
    );
    ros.connect();

    // 等待连接成功
    while (true) {
      if (rosConnectState_ == Status.connected) {
        print("ros connect success!");
        break;
      } else if (rosConnectState_ == Status.closed ||
          rosConnectState_ == Status.errored) {
        print("ros connect failed!");
        return false;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
    Timer(const Duration(seconds: 1), () async {
      await initChannel();
      // await chatter.subscribe();
    });
    return true;
  }

  ValueNotifier<OccupancyMap> get map => map_;
  Future<void> initChannel() async {
    mapChannel_ = Topic(
        ros: ros,
        name: globalSetting.mapTopic,
        type: "nav_msgs/OccupancyGrid",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    mapChannel_.subscribe(mapCallback);

    tfChannel_ = Topic(
      ros: ros,
      name: "/tf",
      type: "tf2_msgs/TFMessage",
      queueSize: 1,
      reconnectOnClose: true,
    );
    tfChannel_.subscribe(tfCallback);

    tfStaticChannel_ = Topic(
      ros: ros,
      name: "/tf_static",
      type: "tf2_msgs/TFMessage",
      queueSize: 1,
      reconnectOnClose: true,
    );
    tfStaticChannel_.subscribe(tfStaticCallback);

    laserChannel_ = Topic(
      ros: ros,
      name: globalSetting.laserTopic,
      type: "sensor_msgs/LaserScan",
      queueSize: 1,
      reconnectOnClose: true,
    );

    laserChannel_.subscribe(laserCallback);

    localPathChannel_ = Topic(
      ros: ros,
      name: globalSetting.localPathTopic,
      type: "nav_msgs/Path",
      queueSize: 1,
      reconnectOnClose: true,
    );
    localPathChannel_.subscribe(localPathCallback);

    globalPathChannel_ = Topic(
      ros: ros,
      name: globalSetting.globalPathTopic,
      type: "nav_msgs/Path",
      queueSize: 1,
      reconnectOnClose: true,
    );
    globalPathChannel_.subscribe(globalPathCallback);

    odomChannel_ = Topic(
      ros: ros,
      name: globalSetting.odomTopic,
      type: 'nav_msgs/Odometry',
      queueSize: 10,
      queueLength: 10,
    );
    odomChannel_.subscribe(odomCallback);

    batteryChannel_ = Topic(
      ros: ros,
      name: globalSetting.batteryTopic, // ROS 中的电池电量话题名称
      type: 'sensor_msgs/BatteryState', // 消息类型
      queueSize: 10,
      queueLength: 10,
    );

    batteryChannel_.subscribe(batteryCallback);

    // imageTopic_ = Topic(
    //   ros: ros,
    //   name: globalSetting.imageTopic,
    //   type: "sensor_msgs/Image",
    //   reconnectOnClose: true,
    //   queueLength: 10,
    //   queueSize: 10,
    // );

    // imageTopic_.subscribe(imageCallback);

//发布者
    relocChannel_ = Topic(
      ros: ros,
      name: globalSetting.relocTopic,
      type: "geometry_msgs/PoseWithCovarianceStamped",
      queueSize: 1,
      reconnectOnClose: true,
    );
    navGoalChannel_ = Topic(
      ros: ros,
      name: globalSetting.navGoalTopic,
      type: "geometry_msgs/PoseStamped",
      queueSize: 1,
      reconnectOnClose: true,
    );
    speedCtrlChannel_ = Topic(
      ros: ros,
      name: globalSetting.getConfig("SpeedCtrlTopic"),
      type: "geometry_msgs/Twist",
      queueSize: 1,
      reconnectOnClose: true,
    );
  }

  Future<void> sendNavigationGoal(RobotPose pose) async {
    Offset p = map_.value.idx2xy(Offset(pose.x, pose.y));
    pose.x = p.dx;
    pose.y = p.dy;
    vm.Quaternion quaternion = eulerToQuaternion(pose.theta, 0, 0);
    Map<String, dynamic> msg = {
      "header": {
        // "seq": 0,
        "stamp": {
          "secs": DateTime.now().second,
          "nsecs": DateTime.now().millisecond * 1000000
        },
        "frame_id": "map"
      },
      "pose": {
        "position": {"x": pose.x, "y": pose.y, "z": 0},
        "orientation": {
          "x": quaternion.x,
          "y": quaternion.y,
          "z": quaternion.z,
          "w": quaternion.w
        }
      }
    };

    // Assuming `channel` is a pre-configured MethodChannel connected to ROS
    try {
      await navGoalChannel_.publish(msg);
    } catch (e) {
      print("Failed to send navigation goal: $e");
    }
  }

  void destroyConnection() async {
    await mapChannel_.unsubscribe();
    await ros.close();
  }

  void setVxRight(double vx) {
    if (vxLeft_ == 0) {
      cmdVel_.vx = vx;
    }
  }

  void setVx(double vx) {
    vxLeft_ = vx;
    cmdVel_.vx = vx;
  }

  void setVy(double vy) {
    cmdVel_.vy = vy;
  }

  void setVw(double vw) {
    cmdVel_.vw = vw;
  }

  void startMunalCtrl() {
    cmdVelTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      await sendSpeed(cmdVel_.vx, cmdVel_.vy, cmdVel_.vw);
    });
  }

  void stopMunalCtrl() {
    if (cmdVelTimer != null) {
      cmdVelTimer!.cancel();
      cmdVelTimer = null;
    }
  }

  Future<void> sendSpeed(double vx, double vy, double vw) async {
    print('89898989${vx}==${vy}==${vw}');
    Map<String, dynamic> msg = {
      "linear": {
        "x": vx, // 代表线速度x分量
        "y": vy, // 代表线速度y分量
        "z": 0.0 // 代表线速度z分量
      },
      "angular": {
        "x": 0.0, // 代表角速度x分量
        "y": 0.0, // 代表角速度y分量
        "z": vw // 代表角速度z分量
      }
    };
    await speedCtrlChannel_.publish(msg);
  }

  Future<void> sendRelocPoseScene(RobotPose pose) async {
    Offset p = map_.value.idx2xy(Offset(pose.x, pose.y));
    pose.x = p.dx;
    pose.y = p.dy;
    vm.Quaternion quation = eulerToQuaternion(pose.theta, 0, 0);
    Map<String, dynamic> msg = {
      "header": {
        // "seq": 0,
        "stamp": {
          "secs": DateTime.now().second,
          "nsecs": DateTime.now().millisecond * 1000000
        },
        "frame_id": "map"
      },
      "pose": {
        "pose": {
          "position": {"x": pose.x, "y": pose.y, "z": 0},
          "orientation": {
            "x": quation.x,
            "y": quation.y,
            "z": quation.z,
            "w": quation.w
          }
        },
        "covariance": [
          0.1,
          0,
          0,
          0,
          0,
          0,
          0,
          0.1,
          0,
          0,
          0,
          0,
          0,
          0,
          0.1,
          0,
          0,
          0,
          0,
          0,
          0,
          0.1,
          0,
          0,
          0,
          0,
          0,
          0,
          0.1,
          0,
          0,
          0,
          0,
          0,
          0,
          0.1
        ]
      }
    };
    try {
      await relocChannel_.publish(msg);
    } catch (e) {
      print("send reloc pose error:$e");
    }
  }

  Future<void> batteryCallback(Map<String, dynamic> message) async {
    double percentage = message['percentage'] * 100; // 假设电量百分比在 0-1 范围内
    battery_.value = percentage;
    // print("battery:$percentage");
    notifyListeners();
  }

  Future<void> odomCallback(Map<String, dynamic> message) async {
    // 解析线速度 (vx, vy)
    double vx = message['twist']['twist']['linear']['x'];
    double vy = message['twist']['twist']['linear']['y'];

    // 解析角速度 (vw)
    double vw = message['twist']['twist']['angular']['z'];
    robotSpeed_.value.vx = vx;
    robotSpeed_.value.vy = vy;
    robotSpeed_.value.vw = vw;
    // print("vx:$vx,vy:$vy,vw:$vw");
    notifyListeners();
  }

  Future<void> tfCallback(Map<String, dynamic> msg) async {
    // print("${json.encode(msg)}");
    tf_.updateTF(TF.fromJson(msg));
    notifyListeners();
  }

  Future<void> tfStaticCallback(Map<String, dynamic> msg) async {
    // print("${json.encode(msg)}");
    tf_.updateTF(TF.fromJson(msg));
    notifyListeners();
  }

  Future<void> localPathCallback(Map<String, dynamic> msg) async {
    localPath.value.clear();
    // print("${json.encode(msg)}");
    RobotPath path = RobotPath.fromJson(msg);
    String framId = path.header!.frameId!;
    RobotPose transPose = RobotPose(0, 0, 0);
    try {
      transPose = tf_.lookUpForTransform(globalSetting.mapFrameName, framId);
    } catch (e) {
      print("not find local path transfrom form:map to:$framId");
      return;
    }

    for (var pose in path.poses!) {
      RosTransform tran = RosTransform(
          translation: pose.pose!.position!, rotation: pose.pose!.orientation!);
      var poseFrame = tran.getRobotPose();
      var poseMap = absoluteSum(transPose, poseFrame);
      Offset poseScene = map_.value.xy2idx(Offset(poseMap.x, poseMap.y));
      localPath.value.add(Offset(poseScene.dx, poseScene.dy));
    }
    notifyListeners();
  }

  Future<void> globalPathCallback(Map<String, dynamic> msg) async {
    globalPath.value.clear();
    RobotPath path = RobotPath.fromJson(msg);
    String framId = path.header!.frameId!;
    RobotPose transPose = RobotPose(0, 0, 0);
    try {
      transPose = tf_.lookUpForTransform("map", framId);
    } catch (e) {
      print("not find global path transfrom form:map to:$framId");
      return;
    }

    for (var pose in path.poses!) {
      RosTransform tran = RosTransform(
          translation: pose.pose!.position!, rotation: pose.pose!.orientation!);
      var poseFrame = tran.getRobotPose();
      var poseMap = absoluteSum(transPose, poseFrame);
      Offset poseScene = map_.value.xy2idx(Offset(poseMap.x, poseMap.y));
      globalPath.value.add(Offset(poseScene.dx, poseScene.dy));
    }
    notifyListeners();
  }

  Uint8List _hexToBytes(String hex) {
    final length = hex.length;
    final buffer = Uint8List(length ~/ 2);
    for (int i = 0; i < length; i += 2) {
      buffer[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return buffer;
  }

  Future<void> imageCallback(Map<String, dynamic> msg) async {
    //int width = msg['width'];
    // int height = msg['height'];
    // String encoding = msg['encoding'];
    // String data = msg['data'].asString();
    //int width = msg['width'];
    // int height = msg['height'];
    // String encoding = msg['encoding'];
    // String data = msg['data'].asString();

    // Uint8List bytes = _hexToBytes(data);
    // print(data.length);
    // print(data.length);
    // Uint8L
    // Uint8List bytes = Uint8List.fromList(data.cast<int>());

    // img.Image? image;
    // if (encoding == 'rgb8') {
    //   image = img.Image.fromBytes(width: width, height: height, bytes: bytes);
    // } else if (encoding == 'mono8') {
    //   image = img.Image.fromBytes(width, height, bytes,
    //       format: img.Format.luminance);
    // } else {
    //   print('Unsupported image encoding: $encoding');
    //   return null;
    // }
  }

  Future<void> laserCallback(Map<String, dynamic> msg) async {
    // print("${json.encode(msg)}");
    LaserScan laser = LaserScan.fromJson(msg);
    RobotPose laserPoseBase = RobotPose(0, 0, 0);
    try {
      laserPoseBase = tf_.lookUpForTransform(
          globalSetting.baseLinkFrameName, laser.header!.frameId!);
    } catch (e) {
      print("not find transform from:map to ${laser.header!.frameId!}");
      return;
    }
    // print("find laser size:${laser.ranges!.length}");
    double angleMin = laser.angleMin!.toDouble();
    double angleMax = laser.angleMax!.toDouble();
    double angleIncrement = laser.angleIncrement!;
    laserPoint_.value.clear();
    for (int i = 0; i < laser.ranges!.length; i++) {
      double angle = angleMin + i * angleIncrement;
      // print("${laser.ranges![i]}");
      if (laser.ranges![i].isInfinite || laser.ranges![i].isNaN) continue;
      double dist = laser.ranges![i];
      //null数据处理
      if (dist == -1) continue;
      RobotPose poseLaser = RobotPose(dist * cos(angle), dist * sin(angle), 0);

      //转换到map坐标系
      RobotPose poseBaseLink = absoluteSum(laserPoseBase, poseLaser);

      laserPoint_.value.add(Offset(poseBaseLink.x, poseBaseLink.y));
    }
    laserPointData.value = LaserData(
        robotPose: currRobotPose_.value, laserPoseBaseLink: laserPoint_.value);
    notifyListeners();
  }

  DateTime? _lastMapCallbackTime;

  Future<void> mapCallback(Map<String, dynamic> msg) async {
    DateTime currentTime = DateTime.now(); // 获取当前时间

    if (_lastMapCallbackTime != null) {
      Duration difference = currentTime.difference(_lastMapCallbackTime!);
      if (difference.inSeconds < 5) {
        return;
      }
    }

    _lastMapCallbackTime = currentTime; // 更新上一次回调时间

    OccupancyMap map = OccupancyMap();
    map.mapConfig.resolution = msg["info"]["resolution"];
    map.mapConfig.width = msg["info"]["width"];
    map.mapConfig.height = msg["info"]["height"];
    map.mapConfig.originX = msg["info"]["origin"]["position"]["x"];
    map.mapConfig.originY = msg["info"]["origin"]["position"]["y"];
    List<int> dataList = List<int>.from(msg["data"]);
    map.data = List.generate(
      map.mapConfig.height, // 外层列表的长度
      (i) => List.generate(
        map.mapConfig.width, // 内层列表的长度
        (j) => 0, // 初始化值
      ),
    );
    for (int i = 0; i < dataList.length; i++) {
      int x = i ~/ map.mapConfig.width;
      int y = i % map.mapConfig.width;
      map.data[x][y] = dataList[i];
    }
    map.setFlip();
    map_.value = map;
    notifyListeners();
  }

  String msgReceived = '';
  Future<void> subscribeHandler(Map<String, dynamic> msg) async {
    msgReceived = json.encode(msg);
    print("recv ${msgReceived}");
  }
}
