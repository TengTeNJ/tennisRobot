import 'dart:async';
import 'dart:math';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:tennis_robot/basic/RobotPose.dart';
import 'package:tennis_robot/basic/gamepad_widget.dart';
import 'package:tennis_robot/basic/gamepad_widget.dart';
import 'package:tennis_robot/basic/math.dart';
import 'package:tennis_robot/basic/matrix_gesture_detector.dart';
import 'package:tennis_robot/basic/occupancy_map.dart';
import 'package:tennis_robot/display/display_laser.dart';
import 'package:tennis_robot/display/display_path.dart';
import 'package:tennis_robot/display/display_robot.dart';
import 'package:tennis_robot/display/display_pose_direction.dart';
import 'package:tennis_robot/global/setting.dart';
import 'package:tennis_robot/provider/global_state.dart';
import 'package:tennis_robot/provider/ros_channel.dart';
import 'package:tennis_robot/display/display_map.dart';
import 'package:tennis_robot/display/display_grid.dart';
import 'package:tennis_robot/utils/robot_manager.dart';
import 'package:tennis_robot/utils/string_util.dart';
import 'package:tennis_robot/utils/toast.dart';
import 'package:toast/toast.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:tennis_robot/display/display_waypoint.dart';

import '../Constant/constants.dart';
import '../models/CourtModel.dart';
import '../utils/data_base.dart';
import 'dart:ui' as ui;

import '../utils/dialog.dart';

class MapPage extends StatefulWidget {
  Function? nextClick;
  String nextTitle;

  //const MapPage({super.key});
  MapPage({this.nextClick,required this.nextTitle});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  GlobalKey _globalKey = GlobalKey();

  ValueNotifier<bool> manualCtrlMode_ = ValueNotifier(false);
  ValueNotifier<List<RobotPose>> navPointList_ =
      ValueNotifier<List<RobotPose>>([]);
  final ValueNotifier<Matrix4> gestureTransform =
      ValueNotifier(Matrix4.identity());

  bool showCamera = false;

  Offset camPosition = Offset(30, 10); // 初始位置
  bool isCamFullscreen = false; // 是否全屏
  Offset camPreviousPosition = Offset(30, 10); // 保存进入全屏前的位置
  late double camWidgetWidth;
  late double camWidgetHeight;

  Matrix4 cameraFixedTransform = Matrix4.identity(); //固定相机视角(以机器人为中心)
  double cameraFixedScaleValue_ = 1; //固定相机视角时的缩放值

  late AnimationController animationController;
  late Animation<double> animationValue;

  final ValueNotifier<RobotPose> robotPose_ = ValueNotifier(RobotPose(0, 0, 0));
  final ValueNotifier<double> gestureScaleValue_ = ValueNotifier(1);
  OverlayEntry? _overlayEntry;
  RobotPose currentNavGoal_ = RobotPose.zero();
  // 定义一个变量用于表示是否达到目标点
  final ValueNotifier<bool> hasReachedGoal_ = ValueNotifier(false);
  final ValueNotifier<double> currentRobotSpeed_ = ValueNotifier(0);

  bool isLandscape = false; // 用于跟踪屏幕方向
  int poseDirectionSwellSize = 10; //机器人方向旋转控件膨胀的大小
  double navPoseSize = 15; //导航点的大小
  double robotSize = 20; //机器人坐标的大小
  RobotPose poseSceneStartReloc = RobotPose(0, 0, 0);
  RobotPose poseSceneOnReloc = RobotPose(0, 0, 0);
  double calculateApexAngle(double r, double d) {
    // 使用余弦定理求顶角的余弦值
    double cosC = (r * r + r * r - d * d) / (2 * r * r);
    // 计算顶角弧度
    double apexAngleRadians = acos(cosC);
    return apexAngleRadians;
  }

  @override
  void initState() {
    super.initState();
    globalSetting.setMaxVx('1.0');
    globalSetting.setMaxVy('1.0');
    globalSetting.setMaxVw('1.0');
    globalSetting.setMapTopic('/map');
    globalSetting.setLaserTopic('/scan');

    globalSetting.init();
    // 初始化 AnimationController
    animationController = AnimationController(
      duration: const Duration(seconds: 2), // 动画持续 1 秒
      vsync: this,
    );

    // 初始化 Tween，从 1.0 到 2.0
    animationValue =
        Tween<double>(begin: 1.0, end: 4.0).animate(animationController)
          ..addListener(() {
            setState(() {
              cameraFixedScaleValue_ =
                  animationValue.value; // 更新 cameraFixedScaleValue_
            });
          }); // 监听 robotPose_ 的变化，判断是否达到目标点
    robotPose_.addListener(() {
      // 获取机器人当前速度
      double distance = calculateDistance(robotPose_.value, currentNavGoal_);

      // 如果距离小于0.5，判断速度为0时候， 表示已达到目标点
      if (currentRobotSpeed_.value < 0.001 &&
          rad2deg(currentRobotSpeed_.value) < 0.01) {
        hasReachedGoal_.value = true;
      } else {
        hasReachedGoal_.value = false;
      }

      // print(currentRobotSpeed_.value);
      // print(rad2deg(currentRobotSpeed_.value));
      // print(robotPose_);
      // print(currentNavGoal_);
      // print(hasReachedGoal_.value);
    });
  }

// 计算两点之间的距离的方法
  double calculateDistance(RobotPose pose1, RobotPose pose2) {
    double dx = pose1.x - pose2.x;
    double dy = pose1.y - pose2.y;
    return sqrt(dx * dx + dy * dy);
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;
    final menuOverlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: Text("确定")),
                    TextButton(
                        onPressed: () {
                          _hideContextMenu();
                        },
                        child: Text("取消"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    menuOverlay?.insert(_overlayEntry!);
  }

  void _hideContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 显示航点编辑窗口的方法
  void showEditNavigationPoints(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Offset offset = Offset.zero; // 初始偏移量
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onPanUpdate: (details) {
                // 更新偏移量，实现拖动效果
                setState(() {
                  offset += details.delta;
                });
              },
              child: Transform.translate(
                offset: offset,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400), // 设置最大宽度
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '航点编辑',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ValueListenableBuilder<List<RobotPose>>(
                              valueListenable: navPointList_,
                              builder: (context, navPointList, child) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 300),
                                  child: ReorderableListView(
                                    shrinkWrap: true,
                                    onReorder: (int oldIndex, int newIndex) {
                                      if (newIndex > oldIndex) {
                                        newIndex -= 1;
                                      }
                                      final item =
                                          navPointList.removeAt(oldIndex);
                                      navPointList.insert(newIndex, item);
                                      navPointList_.value =
                                          List.from(navPointList);
                                    },
                                    children: [
                                      for (int index = 0;
                                          index < navPointList.length;
                                          index++)
                                        ListTile(
                                          key: ValueKey(index),
                                          title: Text('航点 ${index + 1}'),
                                          subtitle: Text(
                                              '坐标: (${navPointList[index].x}, ${navPointList[index].y})'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  editNavigationPoint(
                                                      context, index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  navPointList_.value = List
                                                      .from(navPointList_.value)
                                                    ..removeAt(index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.navigation),
                                                onPressed: () {
                                                  executeNavigation(
                                                      navPointList[index]);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 关闭窗口
                                  },
                                  child: Text('关闭'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    executeMultipleNavigation();
                                  },
                                  child: Text('多点导航'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 示例：执行单点导航的函数
  void executeNavigation(RobotPose pose) {
    // 创建 pose 的副本，避免修改原始值
    RobotPose targetPose = RobotPose(pose.x, pose.y, pose.theta);

    // print(targetPose); // 打印副本以确保不改变原始 pose
    Provider.of<RosChannel>(context, listen: false)
        .sendNavigationGoal(targetPose);
    print("执行单点导航到: (${pose.x}, ${pose.y}, ${pose.theta})");

    currentNavGoal_ = pose;
  }

  // 示例：执行多点导航的函数
  // 异步函数执行多点导航
  Future<void> executeMultipleNavigation() async {
    List<RobotPose> points = List.from(navPointList_.value);

    for (RobotPose point in points) {
      // 创建 pose 的副本，避免修改原始值
      RobotPose targetPose = RobotPose(point.x, point.y, point.theta);
      // 发送导航目标
      Provider.of<RosChannel>(context, listen: false)
          .sendNavigationGoal(targetPose);
      print("执行单点导航到: (${point.x}, ${point.y}, ${point.theta})");

      currentNavGoal_ = point;

      // 等待 hasReachedGoal_ 变为 true，表示已到达目标点
      await waitForGoalReached();

      print("已到达目标点: (${point.x}, ${point.y}, ${point.theta})");
    }

    print("多点导航完成");
  }

  // 等待函数，当 hasReachedGoal_ 变为 true 时返回
  Future<void> waitForGoalReached() async {
    // 使用 Completer 实现异步等待
    Completer<void> completer = Completer<void>();

    // 创建监听器
    void listener() {
      if (hasReachedGoal_.value) {
        completer.complete(); // 达到目标点，完成等待
      }
    }

    // 添加监听器
    hasReachedGoal_.addListener(listener);

    // 等待完成
    await completer.future;

    // 移除监听器，防止内存泄漏
    hasReachedGoal_.removeListener(listener);
  }

  // 编辑航点的方法
  void editNavigationPoint(BuildContext context, int index) {
    var point = navPointList_.value[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController xController =
            TextEditingController(text: point.x.toString());
        TextEditingController yController =
            TextEditingController(text: point.y.toString());

        return AlertDialog(
          title: Text('编辑航点'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: xController,
                decoration: InputDecoration(labelText: 'X 坐标'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: yController,
                decoration: InputDecoration(labelText: 'Y 坐标'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 更新航点的坐标
                point.x = double.parse(xController.text);
                point.y = double.parse(yController.text);
                navPointList_.value = List.from(navPointList_.value)
                  ..[index] = point;
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> takeScreenshot(GlobalKey globayKey) async {
    try {
      RenderRepaintBoundary boundary = globayKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 调整分辨率以适应高像素密度设备
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        if (pngBytes != null) {
          var result =( await ImageGallerySaver.saveImage(pngBytes)).toString();
          print('666000${result}');

        } else {

        }
        return pngBytes;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  void shotScreenAndSaveData() async{
   // String shotImagePath = saveScreenshot(_globalKey);
   var imageData = takeScreenshot(_globalKey);
   if (globalSetting.RobotMapName == ''  || globalSetting.RobotMapLocation == '') {
     //TTToast.showToast('请输入球场信息');
     EasyLoading.showError('请输入球场信息');

     print('没有球场信息');
     return;
   }
   print('有球场信息');

   // print('保存的图片地址为${shotImagePath}');
    /// 本地保存建图信息
    final courtList = await DataBaseHelper().getCourtData(
        kDataBaseCourtTableName);
    if (courtList.length == 0) {
      RobotManager().saveRobotMap(0);
      var todayTime = StringUtil.currentTimeString();
      var model = Courtmodel(
          '0', '', globalSetting.RobotMapName, globalSetting.RobotMapLocation, todayTime);
      DataBaseHelper().insertCourtData(kDataBaseCourtTableName, model);
    } else {
      var model = courtList.last;
      var todayTime = StringUtil.currentTimeString();
      var currentIndex = (int.parse(model.courtIndex) + 1).toString(); //索引递增
      var currentModel = Courtmodel(
          currentIndex, '', globalSetting.RobotMapName,  globalSetting.RobotMapLocation, todayTime);
      DataBaseHelper().insertCourtData(kDataBaseCourtTableName, currentModel);
      RobotManager().saveRobotMap(int.parse(model.courtIndex) + 1);
    }
    /// 球场信息置空
    globalSetting.setRobotMapName('');
    globalSetting.setRobotMapLocation('');
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final _key = GlobalKey<ExpandableFabState>();
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    camWidgetWidth = screenSize.width / 3.5;
    camWidgetHeight =
        camWidgetWidth / (globalSetting.imageWidth / globalSetting.imageHeight);
    camWidgetWidth = screenSize.width / 3.5;
    camWidgetHeight =
        camWidgetWidth / (globalSetting.imageWidth / globalSetting.imageHeight);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: gestureTransform,
            builder: (ctx, child) {
              return Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: MatrixGestureDetector(
                    onMatrixUpdate:
                        (matrix, transDelta, scaleValue, rotateDelta) {
                      if (Provider.of<GlobalState>(context, listen: false)
                              .mode
                              .value ==
                          Mode.robotFixedCenter) {
                        Toast.show("相机视角固定时不可调整图层！",
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                        return;
                      }

                      gestureTransform.value = matrix;
                      gestureScaleValue_.value = scaleValue;
                    },
                    child: ValueListenableBuilder<RobotPose>(
                        valueListenable:
                            Provider.of<RosChannel>(context, listen: false)
                                .robotPoseScene,
                        builder: (context, robotPoseScene, child) {
                          double scaleValue = gestureScaleValue_.value;
                          var globalTransform = gestureTransform.value;
                          var originPose = Offset.zero;
                          if (Provider.of<GlobalState>(context, listen: false)
                                  .mode
                                  .value ==
                              Mode.robotFixedCenter) {
                            scaleValue = cameraFixedScaleValue_;
                            globalTransform = Matrix4.identity()
                              ..translate(screenCenter.dx - robotPoseScene.x,
                                  screenCenter.dy - robotPoseScene.y)
                              ..rotateZ(robotPoseScene.theta - deg2rad(90))
                              ..scale(scaleValue);
                            originPose =
                                Offset(robotPoseScene.x, robotPoseScene.y);
                          }

                          return RepaintBoundary(
                            key: _globalKey,
                            child: Stack(
                              children: [
                                ///网格
                                Container(
                                  child: DisplayGrid(
                                    step: (1 /
                                        Provider.of<RosChannel>(context)
                                            .map
                                            .value
                                            .mapConfig
                                            .resolution) *
                                        (scaleValue > 0.8 ? scaleValue : 0.8),
                                    width: screenSize.width,
                                    height: screenSize.height,
                                  ),
                                ),
                                ///地图
                                Transform(
                                  transform: globalTransform,
                                  origin: originPose,
                                  child: GestureDetector(
                                    child: const DisplayMap(),
                                    onTapDown: (details) {
                                      if (Provider.of<GlobalState>(context,
                                          listen: false)
                                          .mode
                                          .value ==
                                          Mode.addNavPoint) {
                                        navPointList_.value.add(RobotPose(
                                            details.localPosition.dx,
                                            details.localPosition.dy,
                                            0));
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                //全局路径
                                Transform(
                                  transform: globalTransform,
                                  origin: originPose,
                                  child: RepaintBoundary(
                                    child: ValueListenableBuilder<List<Offset>>(
                                      valueListenable: Provider.of<RosChannel>(
                                          context,
                                          listen: false)
                                          .globalPath,
                                      builder: (context, path, child) {
                                        return Container(
                                          child: CustomPaint(
                                            painter: DisplayPath(
                                                pointList: path,
                                                color: Colors.green),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                //局部路径
                                Transform(
                                  transform: globalTransform,
                                  origin: originPose,
                                  child: RepaintBoundary(
                                      child: ValueListenableBuilder<List<Offset>>(
                                        valueListenable: Provider.of<RosChannel>(
                                            context,
                                            listen: false)
                                            .localPath,
                                        builder: (context, path, child) {
                                          return Container(
                                            child: CustomPaint(
                                              painter: DisplayPath(
                                                  pointList: path,
                                                  color: Colors.yellow[200]!),
                                            ),
                                          );
                                        },
                                      )),
                                ),

                                //激光
                                Transform(
                                  transform: globalTransform,
                                  origin: originPose,
                                  child: RepaintBoundary(
                                      child: ValueListenableBuilder<LaserData>(
                                          valueListenable:
                                          Provider.of<RosChannel>(context,
                                              listen: false)
                                              .laserPointData,
                                          builder: (context, laserData, child) {
                                            RobotPose robotPoseMap =
                                                laserData.robotPose;
                                            var map = Provider.of<RosChannel>(
                                                context,
                                                listen: false)
                                                .map
                                                .value;
                                            //重定位模式 从图层坐标转换
                                            if (Provider.of<GlobalState>(context,
                                                listen: false)
                                                .mode
                                                .value ==
                                                Mode.reloc) {
                                              Offset poseMap = map.idx2xy(Offset(
                                                  poseSceneOnReloc.x,
                                                  poseSceneOnReloc.y));
                                              robotPoseMap = RobotPose(
                                                  poseMap.dx,
                                                  poseMap.dy,
                                                  poseSceneOnReloc.theta);
                                            }

                                            List<Offset> laserPointsScene = [];
                                            for (var point
                                            in laserData.laserPoseBaseLink) {
                                              RobotPose pointMap = absoluteSum(
                                                  robotPoseMap,
                                                  RobotPose(
                                                      point.dx, point.dy, 0));
                                              Offset pointScene = map.xy2idx(
                                                  Offset(pointMap.x, pointMap.y));
                                              laserPointsScene.add(pointScene);
                                            }
                                            return IgnorePointer(
                                                ignoring: true,
                                                child: DisplayLaser(
                                                    pointList: laserPointsScene));
                                          })),
                                ),
                                //导航点
                                ...navPointList_.value.map((pose) {
                                  return Transform(
                                    transform: globalTransform,
                                    origin: originPose,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..translate(
                                            pose.x -
                                                navPoseSize / 2 -
                                                poseDirectionSwellSize / 2,
                                            pose.y -
                                                navPoseSize / 2 -
                                                poseDirectionSwellSize / 2)
                                        ..rotateZ(-pose.theta),
                                      child: MatrixGestureDetector(
                                        onMatrixUpdate: (matrix, transDelta,
                                            scaleDelta, rotateDelta) {
                                          if (Provider.of<GlobalState>(context,
                                              listen: false)
                                              .mode
                                              .value ==
                                              Mode.addNavPoint) {
                                            // 移动距离的delta距离需要除于当前的scale的值
                                            double dx =
                                                transDelta.dx / scaleValue;
                                            double dy =
                                                transDelta.dy / scaleValue;
                                            double tmpTheta = pose.theta;
                                            pose = absoluteSum(
                                                RobotPose(
                                                    pose.x, pose.y, pose.theta),
                                                RobotPose(dx, dy, 0));
                                            pose.theta = tmpTheta;
                                            setState(() {});
                                          }
                                        },
                                        child: GestureDetector(
                                          onDoubleTap: () {
                                            if (Provider.of<GlobalState>(context,
                                                listen: false)
                                                .mode
                                                .value ==
                                                Mode.addNavPoint) {
                                              // 双击删除导航点
                                              navPointList_.value =
                                              List.from(navPointList_.value)
                                                ..remove(pose);
                                              setState(() {});
                                            }
                                          },
                                          onPanUpdate: (details) {
                                            if (Provider.of<GlobalState>(context,
                                                listen: false)
                                                .mode
                                                .value ==
                                                Mode.addNavPoint) {
                                              // 更新导航点位置
                                              double dx =
                                                  details.delta.dx / scaleValue;
                                              double dy =
                                                  details.delta.dy / scaleValue;
                                              pose.x += dx;
                                              pose.y += dy;
                                              setState(() {});
                                            }
                                          },
                                          child: Container(
                                            height: navPoseSize +
                                                poseDirectionSwellSize,
                                            width: navPoseSize +
                                                poseDirectionSwellSize,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Visibility(
                                                  visible:
                                                  Provider.of<GlobalState>(
                                                      context,
                                                      listen: false)
                                                      .mode
                                                      .value ==
                                                      Mode.addNavPoint,
                                                  child: DisplayPoseDirection(
                                                    size: navPoseSize +
                                                        poseDirectionSwellSize,
                                                    initAngle: -pose.theta,
                                                    resetAngle: false,
                                                    onRotateCallback: (angle) {
                                                      pose.theta = -angle;
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTapDown: (details) {
                                                    if (Provider.of<GlobalState>(
                                                        context,
                                                        listen: false)
                                                        .mode
                                                        .value ==
                                                        Mode.normal) {
                                                      Provider.of<RosChannel>(
                                                          context,
                                                          listen: false)
                                                          .sendNavigationGoal(
                                                          RobotPose(
                                                              pose.x,
                                                              pose.y,
                                                              pose.theta));
                                                      currentNavGoal_ = pose;
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: DisplayWayPoint(
                                                    size: navPoseSize,
                                                    color: currentNavGoal_ == pose
                                                        ? Colors.pink
                                                        : Colors.green,
                                                    count: 4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                //机器人位置（固定视角）
                                Visibility(
                                  visible: Provider.of<GlobalState>(context,
                                      listen: false)
                                      .mode
                                      .value ==
                                      Mode.robotFixedCenter,
                                  child: Positioned(
                                    left: screenCenter.dx -
                                        (robotSize / 2 * cameraFixedScaleValue_),
                                    top: screenCenter.dy -
                                        (robotSize / 2 * cameraFixedScaleValue_),
                                    child: Transform(
                                      transform: Matrix4.identity()
                                        ..scale(cameraFixedScaleValue_),
                                      child: DisplayRobot(
                                        direction: deg2rad(-90),
                                        size: robotSize,
                                        color: Colors.blue,
                                        count: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                //机器人位置(不固定视角)
                                Visibility(
                                    visible: Provider.of<GlobalState>(context,
                                        listen: false)
                                        .mode
                                        .value !=
                                        Mode.robotFixedCenter,
                                    child: Transform(
                                      transform: Provider.of<GlobalState>(context,
                                          listen: false)
                                          .mode
                                          .value ==
                                          Mode.robotFixedCenter
                                          ? cameraFixedTransform
                                          : gestureTransform.value,
                                      child: Consumer<RosChannel>(
                                        builder: (context, rosChannel, child) {
                                          if (!(Provider.of<GlobalState>(context,
                                              listen: false)
                                              .mode
                                              .value ==
                                              Mode.reloc)) {
                                            robotPose_.value = robotPoseScene;
                                          }

                                          return Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..translate(
                                                    robotPose_.value.x -
                                                        robotSize / 2 -
                                                        poseDirectionSwellSize /
                                                            2,
                                                    robotPose_.value.y -
                                                        robotSize / 2 -
                                                        poseDirectionSwellSize /
                                                            2)
                                                ..rotateZ(
                                                    -robotPose_.value.theta),
                                              child: MatrixGestureDetector(
                                                onMatrixUpdate: (matrix,
                                                    transDelta,
                                                    scaleDelta,
                                                    rotateDelta) {
                                                  if (Provider.of<GlobalState>(
                                                      context,
                                                      listen: false)
                                                      .mode
                                                      .value ==
                                                      Mode.reloc) {
                                                    //获取global的scale值

                                                    //移动距离的deleta距离需要除于当前的scale的值(放大后，相同移动距离，地图实际移动的要少)
                                                    double dx = transDelta.dx /
                                                        scaleValue;
                                                    double dy = transDelta.dy /
                                                        scaleValue;
                                                    double theta =
                                                        poseSceneOnReloc.theta;
                                                    poseSceneOnReloc =
                                                        absoluteSum(
                                                            RobotPose(
                                                                poseSceneOnReloc
                                                                    .x,
                                                                poseSceneOnReloc
                                                                    .y,
                                                                0),
                                                            RobotPose(dx, dy, 0));
                                                    poseSceneOnReloc.theta =
                                                        theta;
                                                    //坐标变换sum
                                                    robotPose_.value =
                                                        poseSceneOnReloc;
                                                  }
                                                },
                                                child: Container(
                                                  height: robotSize +
                                                      poseDirectionSwellSize,
                                                  width: robotSize +
                                                      poseDirectionSwellSize,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      //重定位旋转框
                                                      Visibility(
                                                        visible:
                                                        Provider.of<GlobalState>(
                                                            context,
                                                            listen:
                                                            false)
                                                            .mode
                                                            .value ==
                                                            Mode.reloc,
                                                        child:
                                                        DisplayPoseDirection(
                                                          size: robotSize +
                                                              poseDirectionSwellSize,
                                                          resetAngle: Provider.of<
                                                              GlobalState>(
                                                              context,
                                                              listen:
                                                              false)
                                                              .mode
                                                              .value !=
                                                              Mode.reloc,
                                                          onRotateCallback:
                                                              (angle) {
                                                            poseSceneOnReloc
                                                                .theta =
                                                            (poseSceneStartReloc
                                                                .theta -
                                                                angle);
                                                            //坐标变换sum
                                                            robotPose_.value =
                                                                RobotPose(
                                                                    poseSceneOnReloc
                                                                        .x,
                                                                    poseSceneOnReloc
                                                                        .y,
                                                                    poseSceneOnReloc
                                                                        .theta);
                                                          },
                                                        ),
                                                      ),

                                                      //机器人图标
                                                      DisplayRobot(
                                                        size: robotSize,
                                                        color: Colors.blue,
                                                        count: 2,
                                                      ),
                                                      // IconButton(
                                                      //   onPressed: () {},
                                                      //   iconSize: robotSize / 2,
                                                      //   icon: Icon(Icons.check),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        },
                                      ),
                                    )),
                              ],

                            ),
                          );
                        }),
                  ));
            },
          ),

          ///菜单栏
          // Positioned(
          //     left: 5,
          //     top: 1,
          //     child: Container(
          //       height: 50,
          //       padding: const EdgeInsets.symmetric(vertical: 8),
          //       child: SingleChildScrollView(
          //         scrollDirection: Axis.horizontal, // 水平滚动
          //         child: Row(
          //           children: [
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //               child: RawChip(
          //                 avatar: Icon(
          //                   const IconData(0xe606, fontFamily: "Speed"),
          //                   color: Colors.green[400],
          //                 ), // 图标放在文本前
          //                 label: ValueListenableBuilder<RobotSpeed>(
          //                     valueListenable:
          //                         Provider.of<RosChannel>(context, listen: true)
          //                             .robotSpeed_,
          //                     builder: (context, speed, child) {
          //                       currentRobotSpeed_.value = speed.vx;
          //                       return Text(
          //                           '${(speed.vx).toStringAsFixed(2)} m/s');
          //                     }),
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //               child: RawChip(
          //                 avatar: const Icon(
          //                     IconData(0xe680, fontFamily: "Speed")), // 图标放在文本前
          //                 label: ValueListenableBuilder<RobotSpeed>(
          //                     valueListenable:
          //                         Provider.of<RosChannel>(context, listen: true)
          //                             .robotSpeed_,
          //                     builder: (context, speed, child) {
          //                       return Text(
          //                           '${rad2deg(speed.vx).toStringAsFixed(2)} deg/s');
          //                     }),
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //               child: RawChip(
          //                 avatar: Icon(
          //                   const IconData(0xe995, fontFamily: "Battery"),
          //                   color: Colors.amber[300],
          //                 ), // 图标放在文本前
          //                 label: ValueListenableBuilder<double>(
          //                     valueListenable: Provider.of<RosChannel>(context,
          //                             listen: false)
          //                         .battery_,
          //                     builder: (context, battery, child) {
          //                       return Text('${battery.toStringAsFixed(2)} %');
          //                     }),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     )),
          //图像
          // Visibility(
          //   visible: showCamera, // 根据需要显示或隐藏
          //   child: Positioned(
          //     left: camPosition.dx,
          //     top: camPosition.dy,
          //     child: GestureDetector(
          //       onPanUpdate: (details) {
          //         if (!isCamFullscreen) {
          //           setState(() {
          //             double newX = camPosition.dx + details.delta.dx;
          //             double newY = camPosition.dy + details.delta.dy;
          //             // 限制位置在屏幕范围内
          //             newX = newX.clamp(0.0, screenSize.width - camWidgetWidth);
          //             newY =
          //                 newY.clamp(0.0, screenSize.height - camWidgetHeight);
          //             camPosition = Offset(newX, newY);
          //           });
          //         }
          //       },
          //       child: Container(
          //         child: Stack(
          //           children: [
          //             LayoutBuilder(
          //               builder: (context, constraints) {
          //                 // 在非全屏状态下，获取屏幕宽高
          //                 double containerWidth = isCamFullscreen
          //                     ? screenSize.width
          //                     : camWidgetWidth;
          //                 double containerHeight = isCamFullscreen
          //                     ? screenSize.height
          //                     : camWidgetHeight;
          //
          //                 return Mjpeg(
          //                   stream:
          //                       'http://${globalSetting.robotIp}:${globalSetting.imagePort}/stream?topic=${globalSetting.imageTopic}',
          //                   isLive: true,
          //                   width: containerWidth,
          //                   height: containerHeight,
          //                   fit: BoxFit.fill,
          //                   // BoxFit.fill：拉伸填充满容器，可能会改变图片的宽高比。
          //                   // BoxFit.contain：按照图片的原始比例缩放，直到一边填满容器。
          //                   // BoxFit.cover：按照图片的原始比例缩放，直到容器被填满，可能会裁剪图片。
          //                 );
          //               },
          //             ),
          //             Positioned(
          //               right: 0,
          //               top: 0,
          //               child: IconButton(
          //                 icon: Icon(
          //                   isCamFullscreen
          //                       ? Icons.fullscreen_exit
          //                       : Icons.fullscreen,
          //                   color: Colors.black,
          //                 ),
          //                 constraints: BoxConstraints(), // 移除按钮的默认大小约束，变得更加紧凑
          //                 onPressed: () {
          //                   setState(() {
          //                     isCamFullscreen = !isCamFullscreen;
          //                     if (isCamFullscreen) {
          //                       // 进入全屏时，保存当前位置，并将位置设为 (0, 0)
          //                       camPreviousPosition = camPosition;
          //                       camPosition = Offset(0, 0);
          //                     } else {
          //                       // 退出全屏时，恢复之前的位置
          //                       camPosition = camPreviousPosition;
          //                     }
          //                   });
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          ///左侧工具栏
          // Positioned(
          //     left: 5,
          //     top: 60,
          //     child: FittedBox(
          //         child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Card(
          //           elevation: 10,
          //           child: Container(
          //             child: Row(
          //               children: [
          //                 IconButton(
          //                     onPressed: () {
          //                       if (!(Provider.of<GlobalState>(context,
          //                                   listen: false)
          //                               .mode
          //                               .value ==
          //                           Mode.reloc)) {
          //                         Provider.of<GlobalState>(context,
          //                                 listen: false)
          //                             .mode
          //                             .value = Mode.reloc;
          //                         poseSceneStartReloc = Provider.of<RosChannel>(
          //                                 context,
          //                                 listen: false)
          //                             .robotPoseScene
          //                             .value;
          //
          //                         poseSceneOnReloc = Provider.of<RosChannel>(
          //                                 context,
          //                                 listen: false)
          //                             .robotPoseScene
          //                             .value;
          //                         setState(() {});
          //                       } else {
          //                         Provider.of<GlobalState>(context,
          //                                 listen: false)
          //                             .mode
          //                             .value = Mode.normal;
          //                       }
          //                       setState(() {});
          //                     },
          //                     icon: Icon(
          //                       const IconData(0xe60f, fontFamily: "Reloc"),
          //                       color: Provider.of<GlobalState>(context,
          //                                       listen: false)
          //                                   .mode
          //                                   .value ==
          //                               Mode.reloc
          //                           ? Colors.green
          //                           : theme.iconTheme.color,
          //                     )),
          //                 Visibility(
          //                     visible: Provider.of<GlobalState>(context,
          //                                 listen: false)
          //                             .mode
          //                             .value ==
          //                         Mode.reloc,
          //                     child: IconButton(
          //                         onPressed: () {
          //                           Provider.of<GlobalState>(context,
          //                                   listen: false)
          //                               .mode
          //                               .value = Mode.normal;
          //                           setState(() {});
          //                         },
          //                         icon: const Icon(
          //                           Icons.close,
          //                           color: Colors.red,
          //                         ))),
          //                 Visibility(
          //                     visible: Provider.of<GlobalState>(context,
          //                                 listen: false)
          //                             .mode
          //                             .value ==
          //                         Mode.reloc,
          //                     child: IconButton(
          //                         onPressed: () {
          //                           Provider.of<GlobalState>(context,
          //                                   listen: false)
          //                               .mode
          //                               .value = Mode.normal;
          //                           Provider.of<RosChannel>(context,
          //                                   listen: false)
          //                               .sendRelocPoseScene(poseSceneOnReloc);
          //                           setState(() {});
          //                         },
          //                         icon: const Icon(Icons.check,
          //                             color: Colors.green))),
          //               ],
          //             ),
          //           ),
          //         ),
          //         //设置导航目标点
          //         Card(
          //           elevation: 10,
          //           child: GestureDetector(
          //             onLongPress: () {
          //               showEditNavigationPoints(context); //长按显示编辑窗口
          //             },
          //             child: IconButton(
          //               icon: Icon(
          //                 const IconData(0xeba1, fontFamily: "NavPoint"),
          //                 color:
          //                     (Provider.of<GlobalState>(context, listen: false)
          //                                 .mode
          //                                 .value ==
          //                             Mode.addNavPoint)
          //                         ? Colors.green
          //                         : theme.iconTheme.color,
          //               ),
          //               onPressed: () {
          //                 var globalState =
          //                     Provider.of<GlobalState>(context, listen: false);
          //                 if (globalState.mode.value == Mode.addNavPoint) {
          //                   globalState.mode.value = Mode.normal;
          //                 } else {
          //                   globalState.mode.value = Mode.addNavPoint;
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //         //显示相机图像
          //         Card(
          //           elevation: 10,
          //           child: IconButton(
          //             icon: Icon(Icons.camera_alt),
          //             color: showCamera ? Colors.green : theme.iconTheme.color,
          //             onPressed: () {
          //               showCamera = !showCamera;
          //               setState(() {});
          //             },
          //           ),
          //         ),
          //
          //         //手动控制
          //         Card(
          //           elevation: 10,
          //           child: IconButton(
          //             icon: Icon(const IconData(0xea45, fontFamily: "GamePad"),
          //                 color:
          //                     Provider.of<GlobalState>(context, listen: false)
          //                             .isManualCtrl
          //                             .value
          //                         ? Colors.green
          //                         : theme.iconTheme.color),
          //             onPressed: () {
          //               print('666888');
          //               if (Provider.of<GlobalState>(context, listen: false)
          //                   .isManualCtrl
          //                   .value) {
          //                 Provider.of<GlobalState>(context, listen: false)
          //                     .isManualCtrl
          //                     .value = false;
          //                 Provider.of<RosChannel>(context, listen: false)
          //                     .stopMunalCtrl();
          //                 setState(() {});
          //               } else {
          //                 Provider.of<GlobalState>(context, listen: false)
          //                     .isManualCtrl
          //                     .value = true;
          //                 Provider.of<RosChannel>(context, listen: false)
          //                     .startMunalCtrl();
          //                 setState(() {});
          //               }
          //             },
          //           ),
          //         )
          //       ],
          //     ))),

          /// 右方菜单栏
          // Positioned(
          //   right: 5,
          //   top: 30,
          //   child: FittedBox(
          //     child: Column(
          //       children: [
          //         IconButton(
          //             onPressed: () {
          //               if (Provider.of<GlobalState>(context, listen: false)
          //                       .mode
          //                       .value ==
          //                   Mode.robotFixedCenter) {
          //                 cameraFixedScaleValue_ += 0.3;
          //               } else {}
          //               setState(() {});
          //             },
          //             icon: const Icon(Icons.zoom_in)),
          //         IconButton(
          //             onPressed: () {
          //               setState(() {
          //                 cameraFixedScaleValue_ -= 0.3;
          //               });
          //             },
          //             icon: const Icon(
          //               Icons.zoom_out,
          //             )),
          //         IconButton(
          //             onPressed: () {
          //               if (Provider.of<GlobalState>(context, listen: false)
          //                       .mode
          //                       .value ==
          //                   Mode.robotFixedCenter) {
          //                 Provider.of<GlobalState>(context, listen: false)
          //                     .mode
          //                     .value = Mode.normal;
          //                 cameraFixedScaleValue_ = 1;
          //               } else {
          //                 Provider.of<GlobalState>(context, listen: false)
          //                     .mode
          //                     .value = Mode.robotFixedCenter;
          //               }
          //               if (animationController.isAnimating) return; // 防止多次触发动画
          //
          //               animationController.reset(); // 重置动画控制器
          //               animationController.forward(); // 启动动画
          //               setState(() {});
          //             },
          //             icon: Icon(Icons.location_searching,
          //                 color:
          //                     Provider.of<GlobalState>(context, listen: false)
          //                                 .mode
          //                                 .value ==
          //                             Mode.robotFixedCenter
          //                         ? Colors.green
          //                         : theme.iconTheme.color)),
          //         IconButton(
          //           onPressed: () {
          //             // 退出操作
          //             Navigator.pop(context); // 返回到上一个页面
          //           },
          //           icon: const Icon(Icons.exit_to_app),
          //           tooltip: '退出',
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          /// 底部菜单栏
          ///
          Positioned(
            bottom: 12,
            right: Constants.screenWidth(context)/2 - 84 -12/2,
            child:
          Container(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(onTap: (){
                    // if (Provider.of<GlobalState>(context, listen: false)
                    //     .mode
                    //     .value ==
                    //     Mode.robotFixedCenter) {
                    //   Provider.of<GlobalState>(context, listen: false)
                    //       .mode
                    //       .value = Mode.normal;
                    //   cameraFixedScaleValue_ = 1;
                    // } else {
                    //   Provider.of<GlobalState>(context, listen: false)
                    //       .mode
                    //       .value = Mode.robotFixedCenter;
                    // }
                    // if (animationController.isAnimating) return; // 防止多次触发动画
                    //
                    // animationController.reset(); // 重置动画控制器
                    // animationController.forward(); // 启动动画

                    TTDialog.robotRedrawMapAlertDialog(context, () async {
                     // NavigatorUtil.pop();
                      /// 重新绘制建图
                      RobotManager().redrawRobotMap();
                    });


                    setState(() {});
                    },
                  child:Container(
                    width: 84,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Constants.mediumWhiteTextWidget('Redraw', 16, Constants.courtListBgColor),
                    ),
                  ),

                  ),
                  SizedBox(width: 12,),
                  GestureDetector(onTap: () {

                    print('标题21111${widget.nextTitle}');
                      widget.nextTitle = 'Save';
                      setState(() {});
                    if (widget.nextClick != null){
                      widget.nextClick!();
                    }
                    print('标题2${widget.nextTitle}');
                    if (widget.nextTitle == 'Save') {
                        shotScreenAndSaveData();
                        // 发送获取建图面积指令
                        RobotManager().readRobotMapArea();
                      }
                    },
                    child:Container(
                      width: 84,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Constants.selectedModelBgColor,
                      ),
                      child: Center(
                        child: Constants.mediumWhiteTextWidget('${widget.nextTitle}', 16, Colors.white),
                      ),
                    ),
                  ),
                 // SizedBox(width: 24,),
                ],
              ),
            ),
          ),
          ),

          /// 控制机器人的原始滑杆
          // Visibility(
          //   child: GamepadWidget(),
          // )
        ],
      ),
    );
  }
}
