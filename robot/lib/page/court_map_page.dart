import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:tennis_robot/control/google_map_view.dart';
import 'package:tennis_robot/page/court_info_input_page.dart';
import 'package:tennis_robot/page/map_page.dart';

import '../Constant/constants.dart';
import 'package:tennis_robot/views/remote_control_view.dart';

import '../provider/global_state.dart';
import '../provider/ros_channel.dart';

class CourtMapPage extends StatefulWidget {
  const CourtMapPage({super.key});

  @override
  State<CourtMapPage> createState() => _CourtMapPageState();
}

class _CourtMapPageState extends State<CourtMapPage> {
  bool showInput = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GlobalState>(context, listen: false)
        .isManualCtrl
        .value = true;
    Provider.of<RosChannel>(context, listen: false)
        .startMunalCtrl();
    setState(() {});
  }

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
                  margin: EdgeInsets.only(top: 45,left: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(onTap: (){
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
                SizedBox(height: 25,),

                Container(
                  color: Constants.selectedModelBgColor,
                  width: Constants.screenWidth(context),
                  height: 372,
                  child: MapPage(nextClick: (){
                    setState(() {
                      showInput = true;
                      print('下一步111');
                    });
                  },),
                ),

               showInput == false ?  Container(  /// 遙控
                 alignment: Alignment.center,
                 margin: EdgeInsets.only(top: 20),
                 child: RemoteControlView(),
               ) :
               Container( /// 球场建图的信息
                 //alignment: Alignment.center,
                 margin: EdgeInsets.only(left: 20,top: 20,right: 20,bottom: 20),
                 child: CourtInfoInputPage(),
               ),
              ]
          ),
        ),
      );
    }

}
