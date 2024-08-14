import 'dart:io';

import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:tennis_robot/startPage/action_controller.dart';
import 'package:tennis_robot/customAppBar.dart';
import 'package:tennis_robot/home/home_page_controller.dart';
import 'package:tennis_robot/profile/profile_controller.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/navigator_util.dart';

import 'constant/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class RootPageController extends StatefulWidget {
  const RootPageController({super.key});

  @override
  State<RootPageController> createState() => _RootPageControllerState();
}

class _RootPageControllerState extends State<RootPageController> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<StatefulWidget> _pageviews = [
    HomePageController(),
    ActionController(),
    ProfileController(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationRequest();
    _pageController = PageController()
     ..addListener(() {
       // 获取当前滑动页面的索引 (取整)
       int currentpage = _pageController.page!.round();
       print(_currentIndex);
       if (_currentIndex != currentpage) {
         setState(() {
           _currentIndex = currentpage;
         });
       }
    });
  }

  void locationRequest() async {
     if (Platform.isAndroid) {
       PermissionStatus location =
       await Permission.location.request();
       if (location == PermissionStatus.granted) {
         print('666 location');
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    NavigatorUtil.init(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: ConvexAppBar(
        backgroundColor: Constants.darkThemeColor,
        style: TabStyle.fixed,
        top: -25,
        items: [
          TabItem(icon: Image.asset('images/bottom/icon_home.png'),activeIcon: Image.asset('images/bottom/icon_home_select.png'), title: 'Home'),
          TabItem(icon: Image.asset('images/bottom/icon_action.png'),activeIcon: Image.asset('images/bottom/icon_action_select.png'), title: ''),
          TabItem(icon: Image.asset('images/bottom/icon_profile.png'),activeIcon: Image.asset('images/bottom/icon_profile_select.png'), title: 'Profile'),
        ],
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
           if (i == 2) {
             NavigatorUtil.push(Routes.connect);//
           }
           },
      ),
      body: _pageviews[_currentIndex],
    );
  }
}
