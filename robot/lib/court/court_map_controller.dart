import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../constant/constants.dart';
import '../route/routes.dart';
import '../utils/navigator_util.dart';
import '../views/remote_control_view.dart';

// 建圖控制器（圖傳通信）
class CourtMapController extends StatefulWidget {
  const CourtMapController({super.key});

  @override
  State<CourtMapController> createState() => _CourtMapControllerState();
}

class _CourtMapControllerState extends State<CourtMapController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.darkControllerColor,
      body: SingleChildScrollView(
      //  color: Constants.darkControllerColor,
        child: Column(
            children: [
              Container(
                width: Constants.screenWidth(context),
                margin: EdgeInsets.only(top: 55,left: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(onTap: (){
                      NavigatorUtil.pop();
                    },
                      child: Container(
                        //  padding: EdgeInsets.all(12.0),
                        padding: EdgeInsets.only(left: 0,top: 12,bottom: 12,right: 24),
                        color:  Constants.darkControllerColor,
                        width: 48,
                        height: 48,
                        child: Image(
                          width:24,
                          height: 24,
                          image: AssetImage('images/base/back.png'),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10),

                      child: Row(
                        children: [
                          Container(
                            width: 65,
                             height: 30,
                             child: Center(
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    width:10,
                                    height: 15,
                                    image: AssetImage('images/connect/battery_icon.png'),
                                  ),

                                  SizedBox(width: 6),
                                   Text('70%',
                                     style: TextStyle(
                                       fontFamily: 'SanFranciscoDisplay',
                                       color: Colors.white,
                                       fontSize: 16,
                                     ),
                                   ),
                                ],
                              ),

                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Constants.courtListBgColor,
                            ),
                          ),


                          SizedBox(width: 12),

                          Container(
                            width: 31,
                            height: 31,
                            child: Center(
                              child: Image(
                                width:9,
                                height: 14,
                                image: AssetImage('images/connect/tip_icon.png'),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Constants.courtListBgColor,
                            ),
                          ),


                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 64,),

              Container(
                color: Constants.selectedModelBgColor,
                width: 300,
                height: 198,
              ),
              SizedBox(height: 54,),
              // 重繪 下一步按鈕
              Container(
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Constants.mediumWhiteTextWidget('Redraw', 16, Constants.courtListBgColor),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Container(
                        width: 84,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          color: Constants.selectedModelBgColor,
                        ),
                        child: Center(
                          child: Constants.mediumWhiteTextWidget('Next', 16, Colors.white),
                        ),
                      ),
                      SizedBox(width: 24,),
                    ],

                  ),

                ),
              ),

              // 遙控
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 40),
                child: RemoteControlView(),
              ),
            ]
        ),
      ),
    );
  }
}
