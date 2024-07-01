import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

class SelectModeController extends StatefulWidget {
  const SelectModeController({super.key});

  @override
  State<SelectModeController> createState() => _SelectModeControllerState();
}

class _SelectModeControllerState extends State<SelectModeController> {
  Color _restBGColor = Constants.selectedModelBgColor;
  Color _trainBGColor = Constants.selectModelBgColor;

  Color _restTextColor = Colors.white;
  Color _trainTextColor = Constants.grayTextColor;

  var _restPicName = 'images/connect/choosed_mode_rest.png';
  var _trainPicName = 'images/connect/choose_mode_training.png';
  var textDes = 'The robots will work anywhere in the stadium';


  void _changeModeRest() {
    setState(() {
      _restBGColor = Constants.selectedModelBgColor;
      _trainBGColor = Constants.selectModelBgColor;
      _restTextColor = Colors.white;
      _trainTextColor = Constants.grayTextColor;

      _restPicName = 'images/connect/choosed_mode_rest.png';
      _trainPicName = 'images/connect/choose_mode_training.png';
      textDes = 'The robots will work anywhere in the stadium';
    });
  }

  void _changeModeTrain() {
    setState(() {
      _restBGColor = Constants.selectModelBgColor;
      _trainBGColor = Constants.selectedModelBgColor;
      _restTextColor = Constants.grayTextColor;
      _trainTextColor = Colors.white;

      _restPicName = 'images/connect/choose_mode_rest.png';
      _trainPicName = 'images/connect/choosed_mode_training.png';
      textDes = 'Robots will not enter the field to work';

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRect(
        child: Container(
          color: Constants.darkControllerColor,
          child: Column(
            children: [
              Container(
                width: Constants.screenWidth(context),
                margin: EdgeInsets.only(top:  112),
                child: Constants.mediumWhiteTextWidget('Select Mode', 24 ,Colors.white),
              ),
              Container(
                margin: EdgeInsets.only(top: 110,left: 24),
                child: Row(
                  children: [
                    GestureDetector(onTap: (){
                      _changeModeRest();
                    },
                      child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _restBGColor),
                      width: (Constants.screenWidth(context) - 48) / 2,
                      height: 221,
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Padding(padding: EdgeInsets.only(top: 53, left: 36),
                             child: Image(
                               width: 90,
                               height: 110,
                               image: AssetImage(_restPicName),
                             ),
                           ),
                           Padding(padding: EdgeInsets.only(top: 22 ,left: 53),
                             child: Constants.mediumWhiteTextWidget('Resting', 16 ,_restTextColor),
                           ),
                         ],
                      ),
                      ),),
                    SizedBox(width: 8),
                    GestureDetector(onTap: (){
                      print(456);
                      _changeModeTrain();
                    },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _trainBGColor),
                        width: (Constants.screenWidth(context) - 48) / 2,
                        height: 221,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(top: 53, left: 36),
                              child: Image(
                                width: 90,
                                height: 110,

                                image: AssetImage(_trainPicName),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 22 ,left: 53),
                              child: Constants.mediumWhiteTextWidget('Training', 16 ,_trainTextColor),
                            ),
                          ],
                        ),
                      ),),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 46),
                child: Constants.mediumWhiteTextWidget(textDes, 16 ,Constants.connectTextColor),
              ),
              GestureDetector(
                onTap: (){
                     NavigatorUtil.push(Routes.selectArea);//
                } ,
                child: Container(
                  child: Center(
                    child: Constants.mediumWhiteTextWidget('Start', 18 ,Colors.white),
                  ),
                  height: 56,
                  margin: EdgeInsets.only(left: 30, right: 30, top: 142),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constants.baseStyleColor,
                  ),
                ),
              )
            ],
          ),
        ),

      ),
    );
  }
}
