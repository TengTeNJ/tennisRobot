import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';

class ActionListView extends StatefulWidget {
  ActionListView(
      {this.assetPath,
      required this.title,
      required this.desc,
      this.code = 0,
      this.unit,
      this.showNext = false});

  bool showNext;
  String? assetPath;
  String title;
  String desc;
  String? unit;
  int code;

  @override
  State<ActionListView> createState() => _ActionListViewState();
}

class _ActionListViewState extends State<ActionListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Constants.screenWidth(context) - 32) / 2.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? '--',
                  style: TextStyle(
                      fontFamily: 'SanFranciscoDisplay',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Constants.grayTextColor),
                ),
                SizedBox(width: 6,),
                widget.showNext ? Image(image: AssetImage('images/base/next.png'),width: 4.5,height: 7.5,) : Container()
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 14),
                  child: Image(
                    image: AssetImage(widget.assetPath ??
                        'images/connect/today_number_icon.png'),
                    width: 20,
                    height: 20,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Constants.boldWhiteTextWidget(widget.desc, 30,
                          height: 0.8),
                      SizedBox(
                        width: 2,
                      ),
                      widget.unit == null
                          ? Container()
                          : Constants.mediumWhiteTextWidget(
                              widget.unit!, 20, Colors.white)
                    ],
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
