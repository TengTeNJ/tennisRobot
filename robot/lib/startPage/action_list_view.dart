import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';

class ActionListView extends StatefulWidget {
  ActionListView({this.assetPath, this.title, this.desc, this.code = 0});

  String? assetPath;
  String? title;
  String? desc;
  int code;

  @override
  State<ActionListView> createState() => _ActionListViewState();
}

class _ActionListViewState extends State<ActionListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: (Constants.screenWidth(context) -32) / 2.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Padding(
               padding: EdgeInsets.only(top: 12,left: 20),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   Text(
                     widget.title ?? '--',
                     style: TextStyle(
                       fontFamily: 'SanFranciscoDisplay',
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                       color: Constants.grayTextColor),
                   )
                 ],
               ),


           ),
           Padding(padding: EdgeInsets.only(left: 20,top: 12),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                   margin: EdgeInsets.only(top: 14),
                   child: Image(
                      image: AssetImage(widget.assetPath ?? 'images/connect/today_number_icon.png' ),
                      width: 20,
                      height: 20,

                   ),
                 ),
                 Container(
                   margin: EdgeInsets.only(left: 8),
                   child: Text(
                     widget.desc ?? '--',
                     // overflow: TextOverflow.ellipsis,
                     style: TextStyle(
                       fontFamily: 'SanFranciscoDisplay',
                       fontWeight: FontWeight.bold,
                       fontSize: 36,
                       color: Colors.white,),
                   ),
                 ),
               ],
             ),
           ),
        ],

      ),

    );
  }
}
