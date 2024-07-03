import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/utils/color.dart';
class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key});

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Constants.screenWidth(context) - 40,
      height: Constants.screenWidth(context) - 40,
      decoration: BoxDecoration(
        color: hexStringToColor('#2B2C30'),
        borderRadius: BorderRadius.circular((Constants.screenWidth(context) - 40)/2.0)
      ),
      child: Stack(
        children: [
          Image(image: AssetImage('images/connect/remote_control.png'))
        ],
      ),
    );
  }
}
