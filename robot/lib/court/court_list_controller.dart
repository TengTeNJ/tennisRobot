import 'package:flutter/material.dart';
import 'package:tennis_robot/court/court_list_view.dart';
import 'package:tennis_robot/models/CourtModel.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/utils/robot_manager.dart';
import '../constant/constants.dart';
import '../utils/data_base.dart';
import '../utils/navigator_util.dart';

// 建圖列表VC
class CourtListController extends StatefulWidget {
  const CourtListController({super.key});

  @override
  State<CourtListController> createState() => _CourtListControllerState();
}

class _CourtListControllerState extends State<CourtListController> {
   var list = List<Courtmodel>;

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
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
                    //  NavigatorUtil.pop();
                      Navigator.pop(context); // 返回到上一个页面
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
                    Text('')
                  ],
                ),
              ),

              Expanded(child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20,top: 32),
                child: CourtListView(datas: []),
              )
              ),

              GestureDetector(onTap: (){
                /// 开启一个新的建图
                RobotManager().openNewRobotMap(1);
                Navigator.pushNamed(context, "/court");
                },
              child: Container(
                margin: EdgeInsets.only(top: 8),
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
