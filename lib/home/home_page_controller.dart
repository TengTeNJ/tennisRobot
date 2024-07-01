import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/customAppBar.dart';

class HomePageController extends StatefulWidget {
  const HomePageController({super.key});

  @override
  State<HomePageController> createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
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
                  margin: EdgeInsets.only(top: 55),
                  child: Constants.mediumWhiteTextWidget('Robot', 22,Colors.white),
                ),
                Container(
                   margin: EdgeInsets.only(top: 27,left: 20,right: 20),
                   child: Image(image: AssetImage('images/home/under_way.png')),
                ),
                Container(
                  width: Constants.screenWidth(context),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 22,left: 20),
                  child: Constants.mediumWhiteTextWidget('Tennis bot', 20,Color.fromRGBO(255, 255, 255, 0.6)),
                ),
                
                Container(
                  width: Constants.screenWidth(context),
                  height: 200,
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 17,left:38 ),
                  child: Constants.mediumWhiteTextWidget('Product Introduction Product Introduction Product Introduction', 16,Color.fromRGBO(255, 255, 255, 0.8)),

                ),

              ],
            ),

          ),
       ),
    );
  }
}
