import 'dart:io';
import 'package:flutter/material.dart';
class SocketUtil {
  RawDatagramSocket? _scoket;
  // 获取socket对象
  Future<RawDatagramSocket> getSocket () async{
    if(this._scoket == null){
      RawDatagramSocket _socket =  await RawDatagramSocket.bind(InternetAddress.loopbackIPv6, 6060);
      return _socket;
    }else{
      return this._scoket!;
    }
  }
}