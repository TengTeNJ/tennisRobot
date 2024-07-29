import 'package:flutter/material.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';
import 'package:tennis_robot/utils/robot_manager.dart';
import '../constant/constants.dart';

class ChooseAreaController extends StatefulWidget {
  const ChooseAreaController({super.key});

  @override
  State<ChooseAreaController> createState() => _ChooseAreaControllerState();
}

enum Mode {
  remind, // 起始位提醒
  chooseArea // 区域选择
}

class _ChooseAreaControllerState extends State<ChooseAreaController> {
  Mode currentMode = Mode.remind;
  Color _currentColor = Constants.selectedModelBgColor;
  Color _BcurrentColor = Constants.baseTextGrayBgColor;

  bool _isHidden = false;
  double _offset = 0.0;

  void _changeColor() {
    setState(() {
      _currentColor = Constants.selectedModelBgColor;
      _BcurrentColor = Constants.baseTextGrayBgColor;
      _isHidden = false;
      _offset = 0;
    });
  }

  void _changeBAreaColor() {
    setState(() {
      _currentColor = Constants.baseTextGrayBgColor;
      _BcurrentColor = Constants.selectedModelBgColor;
      _isHidden = true;
      _offset = (((Constants.screenWidth(context) -58*2) * (813 / 522) / 2) - 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
         child: ClipRect(
           child: Container(
             color: Constants.darkControllerColor,
             child: Column(
               children: [
                 Container(
                   width: Constants.screenWidth(context),
                   margin: EdgeInsets.only(top: 90 ,left: 70 ,right: 70),
                   child:Text(
                     currentMode == Mode.chooseArea ? 'Please select the area where the robot needs to work' :'Please place the robot at the center of the net on the field',
                     textAlign: TextAlign.center,
                     overflow: TextOverflow.visible,
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       height: 1.2,
                       fontFamily: 'SanFranciscoDisplay',
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.only(top: 25),
                   child: Column(
                       children:
                     currentMode == Mode.chooseArea ?  [
                     GestureDetector(onTap: (){
                       _changeColor();
                       // 设置机器人区域
                       RobotManager().setRobotArea(0);
                     },
                       child: Container(
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(4),
                             color: _currentColor),
                         width: 66,
                         height: 24,
                         child: Center(
                           child: Constants.mediumWhiteTextWidget('A', 20, Colors.white),
                         ),
                       ),
                     )
                     ] : [SizedBox(height: 24,)]

                   ),
                 ),
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     currentMode == Mode.remind ?
                     Column(
                       children: [
                         Image.asset(
                             width: 14,
                             height: 14,
                             'images/connect/hook_icon.png'
                         ),
                         SizedBox(
                           height: 7,
                         ),
                         Image.asset(
                           currentMode == Mode.chooseArea ? 'images/connect/robot_icon.png' : 'images/connect/rectangle_icon.png',
                           width: 48,
                           height: 24,
                         ),
                       ]
                     ) : Image.asset(
                       currentMode == Mode.chooseArea ? 'images/connect/robot_icon.png' : 'images/connect/rectangle_icon.png',
                       width: 48,
                       height: 24,
                     ),
                     Container(
                       width: Constants.screenWidth(context) -58*2 ,
                       margin: EdgeInsets.only(top: 10,left: 8),
                       height: (Constants.screenWidth(context) -58*2) * (813 / 522) ,
                       child: Stack(
                         children: [
                           Image.asset('images/connect/select_area_line.png'),
                           Container(
                             margin: EdgeInsets.only(top: _offset, left: 5),
                             color: currentMode == Mode.chooseArea ? Constants.selectedModelTransparencyBgColor : Colors.transparent,
                             width: Constants.screenWidth(context) -58*2 ,
                             height: (Constants.screenWidth(context) -58*2) * (813 / 522) / 2 + 50, // 场地高度的一半 +50
                             child: Visibility(
                                 maintainAnimation: false,
                                 maintainState: false,
                                 maintainSize: false,//隐藏需要占位，前俩个也需要为true，内部断言会判断,不需要时都为false,maintainState影响是否加载
                                 child: Text( ''),
                                 visible: _isHidden
                             ),
                           ),
                         ],
                         // image: AssetImage('images/connect/select_area_line.png'),
                         // fit: BoxFit.fill,
                       ),
                     ),
                   ],
                 ),
                 Container(
                   margin: EdgeInsets.only(top: 10),
                   child: Column(
                     children:
                     currentMode == Mode.chooseArea ?  [
                     GestureDetector(onTap: (){
                       _changeBAreaColor();
                       // 设置机器人区域
                       RobotManager().setRobotArea(1);
                     },
                       child: Container(
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(4),
                             color: _BcurrentColor),
                         width: 66,height: 24,

                         child: Center(
                           child: Constants.mediumWhiteTextWidget('B', 20, Colors.white),
                         ),
                       ),
                     )
                     ] : [SizedBox(height: 24,)]
                   ),
                 ),

                 GestureDetector(
                   onTap: (){
                     if (currentMode == Mode.chooseArea) {
                       NavigatorUtil.push(Routes.trainMode);
                     }
                     setState(() {
                       currentMode = Mode.chooseArea;
                     });
                   } ,
                   child: Container(
                     child: Center(
                       child: Constants.mediumWhiteTextWidget('Continue', 20 ,Colors.white),
                     ),
                     height: 72,
                     margin: EdgeInsets.only(left: 44, right: 44, top: 50),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Constants.selectedModelBgColor,
                     ),
                   ),
                 ) ,
                 SizedBox(
                   height: 60,
                 ),
               ],
             ),
           ),
         ),
      )
    );
  }
}
