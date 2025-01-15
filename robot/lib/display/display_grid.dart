import 'package:flutter/material.dart';

class DisplayGrid extends StatelessWidget {
  DisplayGrid({required this.step, required this.width, required this.height});
  double step = 20;
  double width = 300;
  double height = 300;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        color: theme.scaffoldBackgroundColor,
        child: CustomPaint(
          isComplex: true,
          willChange: false,
          painter: GridPainter(
            step: step,
            color: Color.fromRGBO(112, 112, 112, 0.5),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  late double step;
  Color color;

  GridPainter({required this.step, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    double y = 0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      y += step;
      if (y <= size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width,  y), paint);
      }

      //print('x的坐标${x}');
      for (double y = 0; y <= size.height; y += step) {
      // canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return step != oldDelegate.step || color != oldDelegate.color;
  }
}
