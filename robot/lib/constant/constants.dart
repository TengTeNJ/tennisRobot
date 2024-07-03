import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Constants {
  // 生成随机数
  static int randomNumberLeftMargin() {
    return Random().nextInt(32);
  }

  static int randomNumberTopMargin() {
    return Random().nextInt(55);
  }
  //  屏幕宽度
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  //  屏幕高度
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Text mediumWhiteTextWidget(String text, double fontSize,Color color,
      {int maxLines = 1,
        TextAlign textAlign = TextAlign.center,
        double height = 1.0}) {
    return Text(
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.clip,
      text,
      style: TextStyle(
          height: height,
          fontFamily: 'SanFranciscoDisplay',
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: fontSize),
    );
  }

  static Text boldWhiteTextWidget(String text, double fontSize,
      {int? maxLines,
        TextAlign textAlign = TextAlign.center,
        double height = 1.0}) {
    return Text(
      textAlign: textAlign,
      maxLines: maxLines,
      text,
      style: TextStyle(
        height: height,
        fontFamily: 'SanFranciscoDisplay',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: fontSize,
      ),
    );
  }

  static Text boldBaseTextWidget(String text, double fontSize,
      {int maxLines = 1,
        TextAlign textAlign = TextAlign.center,
        double height = 1.0}) {
    return Text(
      textAlign: textAlign,
      maxLines: maxLines,
      text,
      style: TextStyle(
          height: height,
          fontFamily: 'SanFranciscoDisplay4',
          fontWeight: FontWeight.bold,
          color: Constants.baseStyleColor,
          fontSize: fontSize),
    );
  }

  static Text actionRegularGreyTextWidget(String text, double fontSize,
      {int? maxLines,
        TextAlign textAlign = TextAlign.center,
        double height = 1.0,
        TextOverflow? overflow}) {
    return Text(
      maxLines: maxLines ?? null,
      textAlign: textAlign,
      text,
      style: TextStyle(
          overflow: overflow,
          height: height,
          fontFamily: 'SanFranciscoDisplay',
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: fontSize),
    );
  }

  static Text mediumBaseTextWidget(String text, double fontSize,
      {int maxLines = 1,
        TextAlign textAlign = TextAlign.center,
        double height = 1.0}) {
    return Text(
      maxLines: maxLines,
      textAlign: textAlign,
      text,
      style: TextStyle(
          height: height,
          fontFamily: 'SanFranciscoDisplay',
          fontWeight: FontWeight.w500,
          color: Constants.baseStyleColor,
          fontSize: fontSize),
    );
  }

  static Color darkThemeColor = Color.fromRGBO(38, 38, 48, 1);
  static Color darkThemeOpacityColor = Color.fromRGBO(41, 41, 54, 0.24);
  static Color baseStyleColor = Color.fromRGBO(248, 133, 11, 1);
  static Color baseGreyStyleColor = Color.fromRGBO(177, 177, 177, 1);
  static Color darkControllerColor = Color.fromRGBO(28, 29, 32, 1);
  static Color baseControllerColor = Color.fromRGBO(41, 41, 54, 1);

  static Color grayTextColor = Color.fromRGBO(156, 156, 156, 1);

  static Color connectTextColor = Color.fromRGBO(204, 204, 204, 1);
  static Color selectModelBgColor = Color.fromRGBO(56, 58, 64, 1);
  static Color selectedModelBgColor = Color.fromRGBO(233, 100, 21, 1);
  static Color baseTextGrayBgColor = Color.fromRGBO(67, 67, 65, 1);
  static Color selectedModelTransparencyBgColor = Color.fromRGBO(233, 100, 21, 0.39);
  static Color selectedModelOrangeBgColor = Color.fromRGBO(233, 100, 21, 1.0);



  static String connectRobotText =
      'Connect your phone to the Bots Wi-Fi name will match your Bots serial number.The password is "Potent".';


}