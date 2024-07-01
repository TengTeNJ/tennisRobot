import 'package:flutter/material.dart';
import '../constant/constants.dart';

/// 功能切换view
class RobotFunctionSwitchView extends StatefulWidget {
  const RobotFunctionSwitchView({super.key});

  @override
  State<RobotFunctionSwitchView> createState() => _RobotFunctionSwitchViewState();
}

class _RobotFunctionSwitchViewState extends State<RobotFunctionSwitchView> {
  @override
  Widget build(BuildContext context) {
    return Container(
       width: Constants.screenWidth(context),
       height:60 ,

       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         // mainAxisSize: MainAxisSize.max,
         children: [
           Container(
                margin: EdgeInsets.only(left: 28),
                width: 60,
                height: 60,
                child: Container(
                  color: Constants.selectModelBgColor,
                  child: Image(image: AssetImage('images/bottom/function_shutdown_icon.png'),),
                ),
              ),
           Container(
             margin: EdgeInsets.only(left: 13),
             child: Container(
               color: Constants.selectModelBgColor,
               child: Image(image: AssetImage('images/bottom/function_reset_icon.png'),),
             ),
           ),
           Container(
             margin: EdgeInsets.only(left: 13),
             child: Container(
               color: Constants.selectModelBgColor,
               child: Image(image: AssetImage('images/bottom/function_train_icon.png'),),
             ),
           ),
           Container(
             margin: EdgeInsets.only(left: 13),
             child: Container(
               color: Constants.selectModelBgColor,
               child: Image(image: AssetImage('images/resetmode/function_control_icon.png'),),
             ),
           ),
         ],
       ),
    );
  }
}
