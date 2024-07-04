import 'package:flutter/material.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

class CancelButton extends StatelessWidget {
  Function? close;

  CancelButton({this.close});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorUtil.pop();
        if (close != null) {
          close!();
        }
      },
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 25,
            height: 25,
            child: Container(
              width: 25,
              height: 25,
              child: Center(
                child: Image(
                  fit: BoxFit.fitWidth,
                  image: AssetImage('images/base/close_icon.png'),
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
