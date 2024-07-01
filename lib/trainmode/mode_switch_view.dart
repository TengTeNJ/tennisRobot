import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';

/// 模式切换view
class ModeSwitchView extends StatefulWidget {
  const ModeSwitchView({super.key});

  @override
  State<ModeSwitchView> createState() => _ModeSwitchViewState();
}

class _ModeSwitchViewState extends State<ModeSwitchView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0.0, 0.0),

      child: Stack(

        children: [
          Container(

            color: Constants.selectModelBgColor, height: 40, width: 178,
            ),
          Positioned(
            left: 5,
            top: 5,
            child: Container(
              color: Constants.selectedModelOrangeBgColor, height: 30, width: 77,
              // child: Text('Area A',
              // ),
              child: Container(
                alignment: Alignment.center,
                child:Constants.mediumWhiteTextWidget('Area A', 15, Colors.white),
              )

            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
               color: Constants.selectModelBgColor, height: 30, width: 77,
                child: Container(
                 alignment: Alignment.center,
                 child:Constants.mediumWhiteTextWidget('Area B', 15, Constants.grayTextColor)
                ),
              ),
            ),
        ],
      ),
    );
  }
}
