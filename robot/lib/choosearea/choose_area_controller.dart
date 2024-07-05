
import 'package:flutter/material.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

import '../constant/constants.dart';

class ChooseAreaController extends StatefulWidget {
  const ChooseAreaController({super.key});

  @override
  State<ChooseAreaController> createState() => _ChooseAreaControllerState();
}

class _ChooseAreaControllerState extends State<ChooseAreaController> {
  Color _currentColor = Constants.selectedModelBgColor;
  Color _BcurrentColor = Constants.baseTextGrayBgColor;

  bool _isHidden = true;
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
                   // child: Constants.mediumWhiteTextWidget('Please select the area where the robot needs to work', 16, Colors.white),
                   child:Text(
                     'Please select the area where the robot needs to work',
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
                     children: [
                       GestureDetector(onTap: (){
                         _changeColor();
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
                     ],
                   ),
                 ),
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Image.asset(
                       'images/connect/robot_icon.png',
                       width: 48,
                       height: 24,
                     ),
                     // Container(
                     //   width: 12 ,
                     //   height: 6,
                     // ),
                     Container(
                       width: Constants.screenWidth(context) -58*2 ,
                       margin: EdgeInsets.only(top: 10,left: 8),
                       height: (Constants.screenWidth(context) -58*2) * (813 / 522) ,
                       child: Stack(
                         children: [
                           Image.asset('images/connect/select_area_line.png'),
                           Container(
                             margin: EdgeInsets.only(top: _offset, left: 5),
                             color: Constants.selectedModelTransparencyBgColor,
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
                     children: [
                       GestureDetector(onTap: (){
                         _changeBAreaColor();
                       },
                         child: Container(
                           decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(4),
                               color: _BcurrentColor),
                           width: 66,
                           height: 24,
                           child: Center(
                             child: Constants.mediumWhiteTextWidget('B', 20, Colors.white),
                           ),
                         ),
                       )
                     ],
                   ),
                 ),

                 GestureDetector(
                   onTap: (){
                     NavigatorUtil.push(Routes.trainMode);
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
