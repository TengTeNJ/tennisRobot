import 'package:flutter/material.dart';
import 'package:tennis_robot/court/court_list_view.dart';
import 'package:tennis_robot/models/CourtModel.dart';
import 'package:tennis_robot/route/routes.dart';

import '../constant/constants.dart';
import '../utils/navigator_util.dart';

// 建圖列表VC
class CourtListController extends StatefulWidget {
  const CourtListController({super.key});

  @override
  State<CourtListController> createState() => _CourtListControllerState();
}

class _CourtListControllerState extends State<CourtListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Constants.darkControllerColor,
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
                    Text('Court',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'tengxun',
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    Text('123456')
                  ],
                ),
              ),

              Expanded(child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20,bottom: 8),
                child: CourtListView(datas: [Courtmodel('', 'courtName', 'courtAddress', 'courtDate'),
                  Courtmodel('', 'courtName', 'courtAddress', 'courtDate'),
                  Courtmodel('', 'courtName', 'courtAddress', 'courtDate')],
                    ),
              )
              ),

            //  SizedBox(height: 8,),

              GestureDetector(onTap: (){
                NavigatorUtil.push(Routes.courtMap);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Constants.addCourtBgColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                height: 152,
                width: Constants.screenWidth(context) - 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('images/court/court_add_icon.png'),
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(height: 9,),
                    Constants.regularWhiteTextWidget('Add New Court', 16,Constants.addCourtTextColor),
                  ],

                ),
              ),
              ),

             SizedBox(height: 8,)
            ]
        ),
      ),
    );

  }
}
