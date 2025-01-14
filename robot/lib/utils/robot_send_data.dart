import 'package:tennis_robot/constant/constants.dart';
import '../models/robot_data_model.dart';
import 'package:tennis_robot/utils/string_util.dart';


enum ManualFetchType {
  device, // 设备信息
  robotStatu,
  warnInfo,
  errorInfo,
  mode,
  speed,
  coordinate,
  ballsInView
}

/*切换机器人模式*/
List<int> changeRobotMode(RobotMode mode) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x35;
  int data = mode.index;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('切换机器人模式:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

/*清零*/
List<int> clearCountData() {
  int start = kDataFrameHeader;
  int length = 5;
  int cmd = 0x38;
  int cs = start + length + cmd;
  int end = kDataFrameFoot;
  print('清零:${[start, length, cmd, cs, end]}');
  return [start, length, cmd, cs, end];
}

/*设置速度*/
List<int> setSpeedData(int speed) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x41;
  int data = speed;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('设置速度:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

/*设置区域*/
List<int> setAreaData(int area) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x39;
  int data = area;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('设置区域:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

/*设置角度*/
List<int> setAngleData(int angle) {
  int start = kDataFrameHeader;
  int length = 7;
  int cmd = 0x45;
  String dataString = angle.toRadixString(2).padLeft(16, '0');
  int data1 = binaryStringToDecimal(dataString.substring(0, 8));
  int data2 = binaryStringToDecimal(dataString.substring(8, 16));
  //int data = angle;
  int cs = start + length + cmd + data1 + data2;
  int end = kDataFrameFoot;
  print('设置角度:${[start, length, cmd, data1, data2, cs, end]}');
  return [start, length, cmd, data1, data2, cs, end];
}

List<int> moveRobotToDesignPosition(int x,int y) {
  int start = kDataFrameHeader;
  int length = 7;
  int cmd = 0x46;
  String xString = x.toRadixString(2).padLeft(16, '0');
  String yString = y.toRadixString(2).padLeft(16, '0');
  int data1 = binaryStringToDecimal(xString.substring(8, 16));
  int data2 = binaryStringToDecimal(yString.substring(8, 16));
  //int data = angle;
  int cs = start + length + cmd + data1 + data2;
  int end = kDataFrameFoot;
  print('设置机器人指定位置角度:${[start, length, cmd, data1, data2, cs, end]}');
  return [start, length, cmd, data1, data2, cs, end];
}

///建图保存  建图保存
List<int> saveRobotMapData(int index) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x47;
  int data = index;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('机器人建图保存:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

///重新绘制建的图
List<int> resetRobotMapData(int index) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x48;
  int data = 0;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('机器人读取建图:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

///读取建的图  读取建的图
List<int> readRobotMapData(int index) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x49;
  int data = index;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('机器人读取建图:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}

List<int> manualFetchData(ManualFetchType type){
  List<int> _cmds = [
    0x20,
    0x32,
    0x33,
    0x34,
    0x36,
    0x42,
    0x43,
    0x44
  ];
  if(type.index  + 1> _cmds.length){
    return [];
  }
  int start = kDataFrameHeader;
  int length = 5;
  int cmd = _cmds[type.index];
  int cs = start + length + cmd;
  int end = kDataFrameFoot;
  print('主动获取:${[start, length, cmd, cs, end]}');
  return [start, length, cmd, cs, end];
}
