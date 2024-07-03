import 'package:flutter/material.dart';

class MyStatsModel {
  int speed = 10; // 速度
  String gameTimer = 'Feb 4 , 2023'; // 数据对应的游戏时间
  String rank = '-'; // 本次数据对应的排名
  // String trainingMode = 'Training Mode '; // 游戏模式
  String indexString = '1';
  String modeId = '1';
  String sceneId = '1';
  bool selected = false; // 选中状态，用于标记数据选中
  double get textWidth {
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
          text: speed.toString(),
          style: TextStyle(
            color: Colors.transparent,
            fontSize: 14,
            fontFamily: 'SanFranciscoDisplay',
            fontWeight: FontWeight.w400,
          ),
      ),
    );
    // 布局文本
    textPainter.layout();
    return textPainter.width;
  }
}
