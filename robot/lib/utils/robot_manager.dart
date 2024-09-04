import 'dart:async';
import 'package:tennis_robot/models/ball_model.dart';
import 'package:tennis_robot/models/robot_data_model.dart';
import 'package:tennis_robot/utils/event_bus.dart';
import 'package:tennis_robot/utils/robot_send_data.dart';
import 'package:tennis_robot/utils/string_util.dart';
import 'package:tennis_robot/utils/tcp_util.dart';
import '../constant/constants.dart';

enum TCPDataType {
  none,
  deviceInfo,
  workStatu,
  warnInfo,
  errorInfo,
  mode,
  finishOneFlag,
  area,
  speed,
  coordinate,
  ballsInView
}

class RobotManager {
  StreamSubscription? _subscription;
  TcpUtil? _utpUtil;

  // 机器人数据模型
  RobotDataModel dataModel = RobotDataModel();

  /*RobotManager设置为单例模型*/
  static RobotManager _instance = RobotManager._sharedInstance();

  factory RobotManager() {
    return _instance;
  }

  RobotManager._sharedInstance();

  // 在需要用到的页面进行数据监听 格式如下，根据不同的TCPDataType类型和自己的需求进行页面刷新
  /*
  *  RobotManager().dataChange = (TCPDataType type)  {

  };
  * */
  Function(TCPDataType type)? dataChange;

  // 数据改变时内部调用
  _triggerCallback({TCPDataType type = TCPDataType.none}) {
    dataChange?.call(type);
  }

  /*开始TCP连接*/
  startTCPConnect() async {
    _utpUtil = TcpUtil.begainTCPSocket();
    _subscription = EventBus().stream.listen((onData) {
      print('onData.runtimeType = ${onData.runtimeType}');
      if (onData.runtimeType.toString().toUpperCase().contains('MAP')) {
        String key = onData['key'];
        if (key != null && key == kTCPDataListen) {
          print('监听到了TCP数据');
          // 获取传递过来的数据数据
          List<int> _data = onData['value'];
          // 解析数据
          parseData(_data);
        }
      }
    });
  }

  /*关闭socket连接*/
  closeSocket() {
    _subscription?.cancel();
    _utpUtil?.closeTCPClient();
  }

  /*设置机器人模式*/
  setRobotMode(RobotMode mode) {
    List<int> data = changeRobotMode(mode);
    // _utpUtil?.sendData(data.toString());
    _utpUtil?.sendListData(data);
  }

  /*设置机器人区域*/
  setRobotArea(int area) {
    List<int> data = setAreaData(area);
    // _utpUtil?.sendData(data.toString());
    _utpUtil?.sendListData(data);
  }

  /*设置机器人速度*/
  setRobotSpeed(int speed) {
    List<int> data = setAreaData(speed);
    _utpUtil?.sendData(data.toString());
  }

  /*清零*/
  clearCount() {
    List<int> data = clearCountData();
    _utpUtil?.sendData(data.toString());
  }

  /*设置机器人移动角度*/
  setRobotAngle(int angle) {
    List<int> data = setAngleData(angle);
    _utpUtil?.sendListData(data);
  }

  /*主动请求某个数据*/
  manualFetch(ManualFetchType type) {
    List<int> data = manualFetchData(type);
    //_utpUtil?.sendData(data.toString());
    //_utpUtil?.sendListData(data);
  }
}

/*数据拆分*/
List<List<int>> splitData(List<int> _data) {
  int a = kDataFrameHeader;
  List<List<int>> result = [];
  int start = 0;
  while (true) {
    int index = _data.indexOf(a, start);
    if (index == -1) break;
    List<int> subList = _data.sublist(start, index);
    result.add(subList);
    start = index + 1;
  }
  if (start < _data.length) {
    List<int> subList = _data.sublist(start);
    result.add(subList);
  }
  return result;
}

List<int> bleNotAllData = []; // 不完整数据 被分包发送的蓝牙数据
bool isNew = true;

parseData(List<int> data) {
  if (data.contains(kDataFrameHeader)) {
    List<List<int>> _datas = splitData(data);
    _datas.forEach((element) {
      if (element == null || element.length == 0) {
        // 空数组
        // print('问题数据${element}');
      } else {
        // 先获取长度
        int length = element[0] - 1; // 获取长度 去掉了帧头
        if (length != element.length) {
          // 说明不是完整数据
          bleNotAllData.addAll(element);
          if (bleNotAllData[0] - 1 == bleNotAllData.length) {
            print('组包1----${element}');
            handleData(bleNotAllData);
            isNew = true;
            bleNotAllData.clear();
          } else {
            isNew = false;
            Future.delayed(Duration(milliseconds: 10), () {
              if (!isNew) {
                bleNotAllData.clear();
              }
            });
          }
        } else {
          handleData(element);
        }
      }
    });
  } else {
    bleNotAllData.addAll(data);
    if (bleNotAllData[0] - 1 == bleNotAllData.length) {
      print('组包2----${data}');
      handleData(bleNotAllData);
      isNew = true;
      bleNotAllData.clear();
    } else {
      isNew = false;
      Future.delayed(Duration(milliseconds: 10), () {
        if (!isNew) {
          bleNotAllData.clear();
        }
      });
    }
    print('蓝牙设备响应数据不合法=${data}');
  }
}

handleData(List<int> element) {
  int cmd = element[1];
  switch (cmd) {
    case ResponseCMDType.finishOneFlag:
      RobotManager()._triggerCallback(type: TCPDataType.finishOneFlag);


    case ResponseCMDType.deviceInfo:
      int switch_data = element[2]; // 开关机
      int power_data = element[3]; // 电量
      // 开关机
      RobotManager().dataModel.powerOn = switch_data == 1;
      print('开关机=======${switch_data}');
      // 电量
      RobotManager().dataModel.powerValue = power_data;
      print('电量=======${power_data}');
      RobotManager()._triggerCallback(type: TCPDataType.deviceInfo);
      break;
    case ResponseCMDType.workStatu:
      int statu_data = element[2];
      RobotManager().dataModel.statu = [
        RobotStatu.standby,
        RobotStatu.ready,
        RobotStatu.work,
        RobotStatu.error
      ][statu_data];
      print('机器人工作状态=======${statu_data}');
      RobotManager()._triggerCallback(type: TCPDataType.workStatu);
      break;
    case ResponseCMDType.mode:
      int mode_data = element[2];
      RobotManager().dataModel.mode =
          [RobotMode.rest, RobotMode.training, RobotMode.remote][mode_data];
      print('机器人模式=======${mode_data}');
      RobotManager()._triggerCallback(type: TCPDataType.mode);
      break;
    case ResponseCMDType.speed:
      int speed_data = element[2];
      RobotManager().dataModel.speed = speed_data;
      print('速度=======${speed_data}');
      RobotManager()._triggerCallback(type: TCPDataType.speed);
      break;
    case ResponseCMDType.warnInfo:
      int warn_data = element[2];
      RobotManager().dataModel.warnStatu = warn_data;
      print('告警信息=======${warn_data}');
      RobotManager()._triggerCallback(type: TCPDataType.warnInfo);
      break;
    case ResponseCMDType.errorInfo:
      int error_data = element[2];
      RobotManager().dataModel.errorStatu = error_data;
      print('故障信息=======${error_data}');
      RobotManager()._triggerCallback(type: TCPDataType.errorInfo);
      break;
    case ResponseCMDType.coordinate:
      if (element.length < 8) {
        print('机器人坐标数据不合法');
        return;
      }
      // 机器人X坐标
      int x_data1 = element[2];
      int x_data2 = element[3];
      String x1String = decimalToBinary8(x_data1);
      String x2String = decimalToBinary8(x_data2);
      // 取出来正负标示位 0 为正 1为负
      bool x_flag = x1String.substring(0, 1) == '0';
      String x_valueString = x1String.substring(1, x1String.length) + x2String;
      int x_value = binaryStringToDecimal(x_valueString);
      print('机器人X坐标=${x_flag ? x_value : (0 - x_value)}');
      RobotManager().dataModel.xPoint = x_flag ? x_value : (0 - x_value);
      // 机器人Y坐标
      int y_data1 = element[4];
      int y_data2 = element[5];
      String y1String = decimalToBinary8(y_data1);
      String y2String = decimalToBinary8(y_data2);
      // 取出来正负标示位 0 为正 1为负
      bool y_flag = y1String.substring(0, 1) == '0';
      String y_valueString = y1String.substring(1, y1String.length) + y2String;
      int y_value = binaryStringToDecimal(y_valueString);
      print('机器人Y坐标=${y_flag ? y_value : (0 - y_value)}');
      RobotManager().dataModel.yPoint = y_flag ? y_value : (0 - y_value);
      // 机器人角度
      int angle_data1 = element[6];
      int angle_data2 = element[7];
      String angle1String = decimalToBinary8(angle_data1);
      String angle2String = decimalToBinary8(angle_data2);
      // 取出来正负标示位 0 为正 1为负
      bool angle_flag = angle1String.substring(0, 1) == '0';
      String angle_valueString =
          angle1String.substring(1, angle1String.length) + angle2String;
      int angle_value = binaryStringToDecimal(angle_valueString);
      print('机器人角度=${angle_flag ? angle_value : (0 - angle_value)}');
      RobotManager().dataModel.angle =
          angle_flag ? angle_value : (0 - angle_value);
      RobotManager()._triggerCallback(type: TCPDataType.coordinate);

      break;
    case ResponseCMDType.ballsInView:
      // 看到的所有球的数量
      int count_data1 = element[2];
      int count_data2 = element[3];
      String count1String = decimalToBinary8(count_data1);
      String count2String = decimalToBinary8(count_data2);
      String valueString = count1String + count2String;
      int balls_count = binaryStringToDecimal(valueString);
      print('球的數量${balls_count}');
      // 每个球占4个字节
      if (element.length < (4 + 4 * balls_count)) {
        print('看到的所有球的数据不合法');
        return;
      }
      // 先清空上次看到的球的数据
      RobotManager().dataModel.inViewBallList.clear();
      for (int i = 0; i < balls_count; i++) {
        BallModel ball = BallModel();
        int x_data1 = element[4 + i * 4];
        int x_data2 = element[5 + i * 4];
        String x1String = decimalToBinary8(x_data1);
        String x2String = decimalToBinary8(x_data2);
        // 取出来正负标示位 0 为正 1为负
        bool x_flag = x1String.substring(0, 1) == '0';
        String x_valueString =
            x1String.substring(1, x1String.length) + x2String;
        int x_value = binaryStringToDecimal(x_valueString);
        print('第${i + 1}个球X坐标=${x_flag ? x_value : (0 - x_value)}');
        ball.xPoint = x_flag ? x_value : (0 - x_value);
        int y_data1 = element[6 + i * 4];
        int y_data2 = element[7 + i * 4];
        String y1String = decimalToBinary8(y_data1);
        String y2String = decimalToBinary8(y_data2);
        // 取出来正负标示位 0 为正 1为负
        bool y_flag = y1String.substring(0, 1) == '0';
        String y_valueString =
            y1String.substring(1, y1String.length) + y2String;
        int y_value = binaryStringToDecimal(y_valueString);
        print('第${i + 1}个球Y坐标=${y_flag ? y_value : (0 - y_value)}');
        ball.yPoint = y_flag ? y_value : (0 - y_value);
        RobotManager().dataModel.inViewBallList.add(ball);
      }
      RobotManager()._triggerCallback(type: TCPDataType.ballsInView);
      break;
  }
}
