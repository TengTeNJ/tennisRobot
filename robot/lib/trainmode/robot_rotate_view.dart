import 'package:flutter/material.dart';

/// 旋转的view
class RobotRotateView extends StatefulWidget {
   RobotRotateView({required this.turns,required this.duration,required this.child});

   double turns; // 1.0代表360度
   int duration;
   Widget child;

  @override
  State<RobotRotateView> createState() => _RobotRotateViewState();
}

class _RobotRotateViewState extends State<RobotRotateView> with SingleTickerProviderStateMixin{
  late AnimationController _controller;

  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this ,
        lowerBound: -double.infinity,
        upperBound: double.infinity
    );
    _controller.value = widget.turns;
  }

  @override
  Widget build(BuildContext context) {
     return RotationTransition(
         turns: _controller,
         child: widget.child,
         // alignment: Alignment.centerLeft,
         alignment: Alignment(-0.8,0),
     );
  }
  
  @override 
  void didUpdateWidget(RobotRotateView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.turns != widget.turns) {
      _controller.animateBack(widget.turns,
        duration: Duration(milliseconds: widget.duration),
        curve: Curves.easeInOut,
      );
    }
  }
}
