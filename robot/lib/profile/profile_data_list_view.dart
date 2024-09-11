import 'package:flutter/material.dart';
import 'package:tennis_robot/profile/profile_list_view.dart';

class ProfileDataListView extends StatefulWidget {
  const ProfileDataListView({super.key});

  @override
  State<ProfileDataListView> createState() => _ProfileDataListViewState();
}

class _ProfileDataListViewState extends State<ProfileDataListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            SizedBox(width: 16,),
            ProfileListView(assetPath: 'images/profile/profile_wifi.png', title: 'Wi-Fi',),
            // SizedBox(width: 7,),
              ProfileListView(assetPath: 'images/profile/profile_roller_speed.png',title: 'Roller Speed'),
            SizedBox(width: 16,)
            ]
        ),
        SizedBox(height: 8,),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 16,),
              ProfileListView(assetPath: 'images/profile/profile_bracelet.png', title: 'Bracelet',),
              // SizedBox(width: 10,),
              ProfileListView(assetPath: 'images/profile/profile_botfollow.png',title: 'Bot Follow'),
              SizedBox(width: 16,)
            ]
        ),
        SizedBox(height: 8,),

        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 25,),
              ProfileListView(assetPath: 'images/profile/profile_fault.png', title: 'Fault',),
            ]
        ),
      ],

    );
  }
}
