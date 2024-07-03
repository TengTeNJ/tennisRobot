import 'package:flutter/material.dart';
import 'dart:ui' as ui;

 Color hexStringToColor(String hex) {
  hex = hex.toUpperCase().replaceFirst('#', '');
  if (hex.length == 6) {
    hex = "FF" + hex;
  }
  return  Color(
      ui.Color.fromARGB(
          int.parse(hex.substring(0, 2), radix: 16),
          int.parse(hex.substring(2, 4), radix:16),
          int.parse(hex.substring(4, 6), radix:16),
          int.parse(hex.substring(6, 8), radix:16)
      ).value
  );
}

Color hexStringToOpacityColor(String hex,double opacity) {
  hex = hex.toUpperCase().replaceFirst('#', '');
  return Color(
      ui.Color.fromRGBO(
          int.parse(hex.substring(0, 2), radix: 16),
          int.parse(hex.substring(2, 4), radix:16),
          int.parse(hex.substring(4, 6), radix:16),
          opacity,
      ).value
  );
}



