import 'package:flutter/material.dart';
import 'package:tennis_robot/trainmode/robot_rotate_view.dart';
import 'package:tennis_robot/trainmode/sector_painter.dart';

///机器人移动 view
class RobotMoveView extends StatefulWidget {
  const RobotMoveView({super.key});

  @override
  State<RobotMoveView> createState() => _RobotMoveViewState();
}

class _RobotMoveViewState extends State<RobotMoveView> {
  double _turns = .0;

  @override
  Widget build(BuildContext context) {
      return Container(
        height: 60,
        child: Row(

            children: [
              // RobotRotateView(
              //   turns: _turns,
              //   duration: 500,
              //   child: const Icon(
              //     Icons.refresh,
              //     size: 50,
              //   ),
              // ),
              Padding(padding: EdgeInsets.all(5),
                child: RobotRotateView(
                  turns: _turns,
                  duration: 1000,
                  child: Image.asset('images/connect/robot_icon.png',
                   width: 50,
                    height: 25,
                  ),
                ),
              ),
               Container(
                 margin: EdgeInsets.only(left: 0),
                 // color: Colors.red,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: SectorPainter(),
                  ),
               ),
            ],
        ),
      );
  }
}
