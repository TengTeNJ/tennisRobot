import 'package:tennis_robot/constant/constants.dart';

import '../models/robot_data_model.dart';

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
List<int> setSpeedData(int  speed) {
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
List<int> setAreaData(int  area) {
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
List<int> setAngleData(int  angle) {
  int start = kDataFrameHeader;
  int length = 6;
  int cmd = 0x45;
  int data = angle;
  int cs = start + length + cmd + data;
  int end = kDataFrameFoot;
  print('设置角度:${[start, length, cmd, data, cs, end]}');
  return [start, length, cmd, data, cs, end];
}




