import 'dart:io';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/utils/event_bus.dart';
class ResponseCMDType {
  static const int none = 0x00; // 默认无
  static const int deviceInfo = 0x20; // 设备信息，包含开机状态、电量等
  static const int workStatu = 0x32; // 机器人状态 0x00 待机\暂停0x01 就绪 0x02 工作中 0x03 故障
  static const int warnInfo = 0x33; // 机器人告警信息
  static const int errorInfo = 0x34; // 机器人故障信息
  static const int mode = 0x36; // 机器人模式
  static const int finishOneFlag = 0x37; // 机器人捡球上报，每捡到一个球 上报一次
  static const int area = 0x40; // 机器人区域
  static const int speed = 0x42; // 机器人速度
  static const int coordinate = 0x43; // 机器人坐标
  static const int ballsInView = 0x44; // 机器人视野的所有数据
}
class TcpUtil {
  Socket? socket;

  //  初始化 并进行创建
  TcpUtil.begainTCPSocket(){
      this._createTCPClient(Constants.kTcpIPAdress, Constants.kTcpPort);
  }

  /*创建TCP连接*/
  Future<Socket?> _createTCPClient(String host, int port) async {
    try {
      final Socket socket = await Socket.connect(host, port);
      // 赋值
      this.socket = socket;
      // 开始接收数据
      this.receiveData();
      return socket;
    } catch (e) {
      print('Error occurred when trying to connect: $e');
      return null;
    }
  }

  /*发送数据*/
  Future<void> sendData(String data) async {
    if (this.socket != null) {
      this.socket!.write(data);
    }
  }

  /*接收数据和监听连接状态*/
  Future<void> receiveData() async {
    if (this.socket != null) {
      this.socket!.listen((List<int> data) {
        print('Received: ${data.map((toElement){
          return decimalToHex(toElement);
        }).toList()}');

        EventBus().sendEvent({
          'key':kTCPDataListen,
          'value':data
        });
      }, onDone: () {
        print('TCP Connection is closed.');
      }, onError: (error) {
        print('TCP Error: $error');
      });
    }
  }

  /*关闭TCP连接*/
  Future<void> closeTCPClient() async {
    if (this.socket != null) {
      this.socket!.close();
    }
  }
}

String decimalToHex(int decimal, {int minWidth = 1}) {
  String hex = decimal.toRadixString(16).toUpperCase();
  return hex.padLeft(minWidth, '0');
}
