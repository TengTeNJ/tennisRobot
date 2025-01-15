import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

import '../global/setting.dart';
import '../provider/ros_channel.dart';

class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key});

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  Offset position = Offset(0, 0); // 初始位置为试图A的中心
  bool isMove = false; // 滑动标识
  int index = 0;// 索引，记录第一次拖动的方向

  // 上一次给机器人发送角度的时间
  DateTime lastTime = DateTime.now();
  DateTime _lastUpdateTime = DateTime.now(); // 记录上次更新的时间


  Offset firstPosition = Offset(0, 0);

  int _topImageIndex = 0;
  List<String> _topImages = [
    'images/control/control_top.png',
    'images/control/control_top_high.png'
  ];

  int _bottomImageIndex = 0;
  List<String> _bottomImages = [
    'images/control/control_bottom.png',
    'images/control/control_bottom_high.png'
  ];

  int _leftImageIndex = 0;
  List<String> _leftImages = [
    'images/control/control_left.png',
    'images/control/control_left_high.png'
  ];

  int _rightImageIndex = 0;
  List<String> _rightImages = [
    'images/control/control_right.png',
    'images/control/control_right_high.png'
  ];

  int interval = 500; //长按发送时间间隔
  Timer? rightMoveTimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Constants.screenWidth(context) - 40 *3,
      height: Constants.screenWidth(context) - 40*3,
      decoration: BoxDecoration(
          color: Color.fromRGBO(43, 44, 48, 1),
          borderRadius: BorderRadius.circular(
              (Constants.screenWidth(context) - 40*3) / 2.0)),
      child: Stack(
        children: [
          Center(
            // child: Image(
            //   image: AssetImage('images/connect/remote_control.png'),
            //   height: Constants.screenWidth(context) - 40*3 - 96,
            // ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 20,
                  left: (Constants.screenWidth(context) - 40*3)/2 - 20,
                  child: GestureDetector(
                    onLongPressStart: ( details) {
                      rightMoveTimer = Timer.periodic(Duration(milliseconds: interval), (timer){
                        setState(() {
                          _topImageIndex = 1;
                          Vibration.vibrate();
                          print('长按向上移动开始');

                        });
                      });
                    },

                    onLongPressEnd: (detail) {
                      // if(rightMoveTimer != null) {
                      rightMoveTimer?.cancel();
                      // }
                      print('长按向上移动结束');

                      setState(() {
                        _topImageIndex = 0;
                      });
                    },

                    child: Image.asset('${_topImages[_topImageIndex]}',width: 40,height: 30), // 替换为你的图片路径
                  ),
                ),
                Positioned(
                  top: (Constants.screenWidth(context) - 40*3) - 30 - 20,
                  right: (Constants.screenWidth(context) - 40*3)/2 - 20,
                  child: GestureDetector(
                    onLongPressStart: ( details) {
                      rightMoveTimer = Timer.periodic(Duration(milliseconds: interval), (timer){
                        setState(() {
                          _bottomImageIndex = 1;
                          Vibration.vibrate();
                        });
                      });
                    },

                    onLongPressEnd: (detail) {
                      // if(rightMoveTimer != null) {
                      rightMoveTimer?.cancel();
                      // }
                      print('长按向下移动结束');

                      setState(() {
                        _bottomImageIndex = 0;
                      });
                    },

                    child: Image.asset('${_bottomImages[_bottomImageIndex]}',width: 40,height: 30), // 替换为你的图片路径
                  ),
                ),
                Positioned(
                  bottom: (Constants.screenWidth(context) - 40*3)/2 - 20,
                  left: 20,
                  child: GestureDetector(
                    onLongPressStart: ( details) {
                      rightMoveTimer = Timer.periodic(Duration(milliseconds: interval), (timer){
                        setState(() {
                          _leftImageIndex = 1;
                          Vibration.vibrate();
                        });
                      });
                    },

                    onLongPressEnd: (detail) {
                      // if(rightMoveTimer != null) {
                      rightMoveTimer?.cancel();
                      // }
                      print('长按向左移动结束');

                      setState(() {
                        _leftImageIndex = 0;
                      });
                    },

                    child: Image.asset('${_leftImages[_leftImageIndex]}',width: 30,height: 40), // 替换为你的图片路径
                  ),
                ),
                Positioned(
                  bottom: (Constants.screenWidth(context) - 40*3)/2 - 20,
                  right:20,
                  child: GestureDetector(
                    onLongPressStart: ( details) {
                      rightMoveTimer = Timer.periodic(Duration(milliseconds: interval), (timer){
                        setState(() {
                          print('长按向右移动');
                          _rightImageIndex = 1;
                          Vibration.vibrate();
                        });
                      });
                    },

                    onLongPressEnd: (detail) {
                      // if(rightMoveTimer != null) {
                      rightMoveTimer?.cancel();
                      // }
                      print('长按向右移动结束');

                      setState(() {
                        _rightImageIndex = 0;
                      });
                    },
                    child: Image.asset('${_rightImages[_rightImageIndex]}',width: 30,height: 40), // 替换为你的图片路径
                  ),
                ),
              ],
            ),

          ),
          Positioned(
              left: (Constants.screenWidth(context) - 40*3 - 44) / 2.0,
              top: (Constants.screenWidth(context) - 40*3 - 44) / 2.0,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    // 开始拖拽
                    isMove = true;
                  });
                },
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  // 更新圆点的位置
                  setState(() {
                    position += details.delta;
                    // 限制圆点在试图A内部移动
                    position = _clampOffsetToCircle(position, ((Constants.screenWidth(context) - 40*3) / 2.0));

                   if (_updateTime(position, 0) > 100) { // 发送角度间隔需大于20毫秒
                     var radius = (Constants.screenWidth(context) - 40 *3) / 2;
                     print('位置信息为${position}');

                     double max_vw =
                     double.parse(globalSetting.getConfig('MaxVw'));
                     double max_vx =
                     double.parse(globalSetting.getConfig('MaxVx'));

                     print('速度MaxVx-${globalSetting.getConfig('MaxVx')}');
                     print('速度MaxVw-${globalSetting.getConfig('MaxVw')}');

                     if (position.dx.abs() > position.dy.abs()) {
                       double vw = max_vw * (position.dx /radius) * -1;
                       Provider.of<RosChannel>(context, listen: false)
                           .setVw(vw);
                       print('轮盘设置的vw为${vw}');
                     } else if (position.dx.abs() < position.dy.abs()) {
                       double vx = max_vx * (position.dy / radius) * -1;
                       Provider.of<RosChannel>(context, listen: false)
                           .setVxRight(vx);
                       print('轮盘设置的vx为${vx}');
                     }
                     if (position.dx.abs() == 0) {
                       Provider.of<RosChannel>(context, listen: false)
                           .setVxRight(0);
                     }
                     if (position.dy.abs() == 0) {
                       Provider.of<RosChannel>(context, listen: false)
                           .setVw(0);
                     }
                   }
                  });
                },
                onPanEnd: (details) {
                  // 手指松开时，将圆点移动回试图A的中心
                  setState(() {
                    Provider.of<RosChannel>(context, listen: false)
                        .setVy(0);
                    Provider.of<RosChannel>(context, listen: false)
                        .setVxRight(0);
                    Provider.of<RosChannel>(context, listen: false)
                        .setVw(0);

                    index = 0;
                    // 结束拖拽
                    firstPosition = Offset(0, 0);
                    position = Offset(0, 0);
                    isMove = false;
                  });
                },
                child: Transform.translate(
                  offset: position,
                  child: Image(
                    image: AssetImage(isMove
                        ? 'images/connect/control_point_move.png'
                        : 'images/connect/control_point.png'),
                    height: 44,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  int _updateTime(Offset position, double timeStamp) {
    // 如果这是第一次调用，记录当前时间
    if (_lastUpdateTime == null) {
      _lastUpdateTime = DateTime.now();
      return 0;
    }

    // 计算时间差
    final timeDifference = DateTime.now().difference(_lastUpdateTime).inMilliseconds;
    print('时间差: $timeDifference');
    if (Platform.isIOS) {
      if (timeDifference > 200) {
        _lastUpdateTime = DateTime.now();
      }
    } else {
      if (timeDifference > 100) {
        _lastUpdateTime = DateTime.now();
      }
    }

    // 更新最后一次时间
    //   _lastUpdateTime = DateTime.now();
    return timeDifference;
  }

  String getCurrentTime() {
    // 获取当前时间
    DateTime now = DateTime.now();
    // 格式化时间为字符串
    String timeString = "${now.hour}:${now.minute}:${now.second}:${now.millisecond}";
    // 打印时间
    // print(timeString);
    return timeString;
  }
  /*限制圆环在圆形内拖拽*/
  Offset _clampOffsetToCircle(Offset offset, double radius) {
    double distanceSquared = offset.dx * offset.dx + offset.dy * offset.dy;
    if (distanceSquared <= radius * radius) {
      // 如果已经在圆内或圆上，则无需调整
      return offset;
    } else {
      // 如果在圆外，则计算到圆边缘的最近点
      double distance = math.sqrt(distanceSquared);
      double x = offset.dx * radius / distance;
      double y = offset.dy * radius / distance;
      return Offset(x, y);
    }
  }
}
