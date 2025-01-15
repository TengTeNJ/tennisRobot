import 'package:flutter/material.dart';
import 'package:tennis_robot/models/CourtModel.dart';

import '../constant/constants.dart';

class CourtListItemView extends StatefulWidget {
  Courtmodel model;

  CourtListItemView({required this.model});

  @override
  State<CourtListItemView> createState() => _CourtListItemViewState();
}

class _CourtListItemViewState extends State<CourtListItemView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        decoration: BoxDecoration(
          color: Constants.courtListBgColor,
          borderRadius: BorderRadius.circular(24),),
        height: 152,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: Constants.screenWidth(context)/2,
                      height: 123,
                      color: Constants.courtGridBgColor,

                  ),
                  SizedBox(width: 12,),
                  Container(
                    margin: EdgeInsets.only(top: 37,left: 0),
                    child: Column(
                     // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Constants.mediumWhiteTextWidget('Potent Test', 16, Colors.white),
                        SizedBox(height: 20,),
                        Container(
                          // padding: EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage('images/court/court_location_icon.png'),
                                width: 7,
                                height:10,),
                               SizedBox(width: 3,),
                              Constants.regularWhiteTextWidget('AXIN Tennis', 12, Constants.grayTextColor),
                            ],
                          ),
                        ),
                        SizedBox(height: 8,),
                        Container(
                          child: Row(
                            children: [
                              Image(
                                image: AssetImage('images/court/court_upload_icon.png'),
                                width: 11,
                                height:7,),
                              SizedBox(width: 3,),

                              Constants.regularWhiteTextWidget('Mar 31,2024 10:30', 12, Constants.grayTextColor),
                            ],
                          ),
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //     margin: EdgeInsets.only(right: 20),
            //     child: Image(
            //       image: AssetImage('images/profile/setting_arrow.png'),
            //       width: 7,
            //       height:13,)
            // ),
          ],

        ),

      ),
    );

  }
}
