import 'package:tennis_robot/constant/constants.dart';
import 'package:flutter/material.dart';

import '../../utils/color.dart';

class BaseButton extends StatelessWidget {
  String title;
  Function? onTap;
  double height;
  BorderRadiusGeometry? borderRadius;
  LinearGradient? linearGradient;



  BaseButton({required this.title, this.height = 44,this.onTap,this.linearGradient,this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      if(onTap!=null){
        onTap!();
      }

    },child: Container(
      height: height,
      width: 151,
      decoration: BoxDecoration(
        // gradient:  linearGradient,
        borderRadius:  borderRadius ?? BorderRadius.circular(10),
        color: Constants.selectedModelOrangeBgColor,),
      child: Center(
        child: Constants.regularWhiteTextWidget(title, 16 ,Colors.white),
      ),
    ),);
  }
}
