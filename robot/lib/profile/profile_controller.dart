import 'package:flutter/material.dart';
import 'package:tennis_robot/profile/profile_data_list_view.dart';
import 'package:tennis_robot/constant/constants.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({super.key});

  @override
  State<ProfileController> createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Constants.darkControllerColor,
         child: Column(
           children: [
             Container(
               width: Constants.screenWidth(context),
               margin: EdgeInsets.only(top: 55),
               child: Constants.mediumWhiteTextWidget('Profile', 22,Colors.white),
             ),
             Container(
               margin: EdgeInsets.only(top: 40),
               child: ProfileDataListView() ,
             ),
           ]
         ),
      ),
    );
  }

}
