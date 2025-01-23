import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennis_robot/global/setting.dart';
//import 'package:geolocator_platform_interface/src/models/position.dart';
import '../Constant/constants.dart';
//import '../basic/transform.dart';

class CourtInfoInputPage extends StatefulWidget {
  const CourtInfoInputPage({super.key});

  @override
  State<CourtInfoInputPage> createState() => _CourtInfoInputPageState();
}

class _CourtInfoInputPageState extends State<CourtInfoInputPage> {
  bool isConnected = false; // 是否
  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String currentLocation = '';

  void getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position? position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    placemarkFromCoordinates(position.latitude, position.longitude)
        .then((placemarks){
      //print('当前地址为${placemarks}');
      var placemark = placemarks[1];
      print('当前地址为${placemark.street}');
      setState(() {
        _emailController.text = placemark.street!;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Container(
           width: Constants.screenWidth(context),
           height: 284,
           decoration: BoxDecoration(
           //  color: Constants.addCourtInfoBgColor,
             color: Color.fromRGBO(39,41, 48, 1.0),
             borderRadius: BorderRadius.circular(20)//
           ),
            child: GestureDetector(onTap: (){
              FocusScope.of(context).unfocus();
              },
                 child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     GestureDetector(onTap: (){
                    //        getCurrentLocation();
                    //        },
                    //       child: Container(
                    //         margin: EdgeInsets.only(right: 12,top: 12),
                    //         alignment: Alignment.topRight,
                    //         width: 84,
                    //         height:34 ,
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(17),
                    //           color: Constants.addCourtTextColor,
                    //         ),
                    //         child: Center(
                    //           child: Constants.mediumWhiteTextWidget('Save', 16, Colors.white),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Container(
                      width: Constants.screenWidth(context),
                      margin: EdgeInsets.only(left: 30, right: 70, top: 56),
                      child: Constants.regularWhiteTextWidget('Court Name', 18, Colors.white,textAlign: TextAlign.left),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 30, right: 70, top: 4),
                      height:44 ,
                      child: TextField(
                        cursorColor: Color.fromRGBO(248, 98, 21, 1),
                        onChanged:(value) {
                          globalSetting.setRobotMapName(value);
                          print('00088888${value}');

                          if (_emailController.text != '' && _nickController.text != ''){
                            setState(() {
                              isConnected = true;
                            });
                          } else {
                            setState(() {
                              isConnected = false;
                            });
                          }
                        },
                        controller: _nickController,
                        style: TextStyle(color: Constants.baseStyleColor), // 设置字体颜色
                        decoration: InputDecoration(
                          hintText: 'Enter Court name', // 占位符文本
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // 设置焦点之外的边框颜色
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(248, 98, 21, 1)), // 设置焦点时的边框颜色
                          ),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(156, 156, 156, 1.0),
                              fontFamily: 'SanFranciscoDisplay',
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),

                    Container(
                      width: Constants.screenWidth(context),
                      margin: EdgeInsets.only(left: 30, right: 70, top: 40),
                      child: Constants.regularWhiteTextWidget('Location', 18, Colors.white,textAlign: TextAlign.left),
                    ),

                    // Container(
                    //   margin: EdgeInsets.only(left: 30, right: 70, top: 4),
                    //   height:44 ,
                    //   child: TextField(
                    //     onChanged:(value) {
                    //       globalSetting.setRobotMapLocation(value);
                    //     },
                    //     controller: _emailController,
                    //     cursorColor: Color.fromRGBO(248, 98, 21, 1),
                    //     style: TextStyle(color: Constants.baseStyleColor), // 设置字体颜色
                    //     decoration: InputDecoration(
                    //       hintText: 'Enter location', // 占位符文本
                    //       focusColor: Colors.red,
                    //       enabledBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.white), // 设置焦点之外的边框颜色
                    //       ),
                    //       focusedBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Color.fromRGBO(248, 98, 21, 1)), // 设置焦点时的边框颜色
                    //       ),
                    //       hintStyle: TextStyle(
                    //           color: Color.fromRGBO(156, 156, 156, 1.0),
                    //           fontFamily: 'SanFranciscoDisplay',
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w400),
                    //     ),
                    //   ),
                    // ),


                    Container(
                      margin: EdgeInsets.only(left: 30, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: Constants.screenWidth(context) - 100 - 40,
                            height:44 ,
                            child: TextField(
                              onChanged:(value) {
                                globalSetting.setRobotMapLocation(value);
                              },
                              controller: _emailController,
                              cursorColor: Color.fromRGBO(248, 98, 21, 1),
                              style: TextStyle(color: Constants.baseStyleColor), // 设置字体颜色
                              decoration: InputDecoration(
                                hintText: 'Enter location', // 占位符文本
                                focusColor: Colors.red,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white), // 设置焦点之外的边框颜色
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromRGBO(248, 98, 21, 1)), // 设置焦点时的边框颜色
                                ),
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(156, 156, 156, 1.0),
                                    fontFamily: 'SanFranciscoDisplay',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),

                         GestureDetector(onTap: (){
                           Navigator.pushNamed(context, "/googlemap");

                         },
                         child: Container(
                           margin: EdgeInsets.only(left: 0),
                           child: Image(
                             image: AssetImage('images/base/right_arrow.png'),
                             width: 7,
                             height: 13,
                           ),
                         )
                         )
                        ],

                      ),
                    ),



                    SizedBox(height: 30),
                  ],
                ),
              ),
             // ),
          //  ),
    );

  }
}
