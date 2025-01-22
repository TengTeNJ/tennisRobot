import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:tennis_robot/basic/occupancy_map.dart';
import 'package:tennis_robot/provider/ros_channel.dart';
import 'dart:ui' as ui;


class DisplayMap extends StatefulWidget {
  const DisplayMap();

  @override
  _DisplayMapState createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  List<MapPoint> occPointList = [];
  List<Offset> freePointList = [];

  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  // 修改处理 map 数据的函数，保存 mapValue 以便后续动态设置透明度
  void _processMapData(OccupancyMap map) {
    occPointList.clear();
    freePointList.clear();
    for (int i = 0; i < map.Cols(); i++) {
      for (int j = 0; j < map.Rows(); j++) {
        int mapValue = map.data[j][i];
        Offset point = Offset(i.toDouble(), j.toDouble());

        if (mapValue > 0) {
          int alpha = (mapValue * 2.55).clamp(0, 255).toInt();
          occPointList.add(MapPoint(point: point, value: alpha));
         // print('occPoint666${point}');
        } else if (mapValue == 0) {
          freePointList.add(point);
         // print('freePoint666${point}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return RepaintBoundary(
        key: _globalKey,
        child: ValueListenableBuilder<OccupancyMap>(
            valueListenable: Provider.of<RosChannel>(context, listen: true).map,
            builder: (context, occMap, child) {
              _processMapData(occMap);
              return Container(
                width: occMap.width().toDouble() + 1,
                height: occMap.height().toDouble() + 1,
                child: CustomPaint(
                  painter: DisplayMapPainter(
                      occPointList: occPointList,
                      freePointList: freePointList,
                    //  freeColor: theme.colorScheme.surface.withAlpha(98),
                      freeColor: Color.fromRGBO(248, 98, 21, 1.0),
                      //occBaseColor: isDarkMode ? Colors.white : Colors.black),
                   occBaseColor: isDarkMode ? Colors.transparent : Colors.yellow),
                ),
              );
            }));
  }
}

class DisplayMapPainter extends CustomPainter {
  final List<MapPoint> occPointList;
  final List<Offset> freePointList;
  final Color freeColor;
  final Color occBaseColor;

  DisplayMapPainter(
      {required this.occPointList,
      required this.freePointList,
      required this.freeColor,
      required this.occBaseColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // 使用 PictureRecorder 缓存绘制内容
    final recorder = PictureRecorder();
    final recordingCanvas = Canvas(recorder);

    // 保存 Canvas 状态
    recordingCanvas.save();

    // 批量绘制占据点
    for (var mapPoint in occPointList) {
      paint.color = occBaseColor.withAlpha(mapPoint.value);
      recordingCanvas.drawPoints(PointMode.points, [mapPoint.point], paint);
    }

    // 批量绘制自由区域
    if (freePointList.isNotEmpty) {
      paint.color = freeColor;
      final freePoints = Float32List.fromList(
          freePointList.expand((point) => [point.dx, point.dy]).toList());
      recordingCanvas.drawRawPoints(PointMode.points, freePoints, paint);
    }

    // 恢复 Canvas 状态
    recordingCanvas.restore();

    // 将录制的内容绘制到实际 Canvas 上
    final picture = recorder.endRecording();
    canvas.drawPicture(picture);
  }

  @override
  bool shouldRepaint(covariant DisplayMapPainter oldDelegate) {
    return oldDelegate.occPointList != occPointList ||
        oldDelegate.freePointList != freePointList ||
        oldDelegate.freeColor != freeColor ||
        oldDelegate.occBaseColor != occBaseColor;
  }
}

// 新建 MapPoint 类来存储位置信息和值
class MapPoint {
  final Offset point;
  final int value;

  MapPoint({required this.point, required this.value});
}
