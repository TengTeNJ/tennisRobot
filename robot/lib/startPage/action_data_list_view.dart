import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tennis_robot/startPage/action_list_view.dart';
import 'package:tennis_robot/utils/color.dart';
import 'package:tennis_robot/views/data_bar_view.dart';
import '../models/my_status_model.dart';

class ActionDataListView extends StatefulWidget {
  const ActionDataListView({super.key});

  @override
  State<ActionDataListView> createState() => _ActionDataListViewState();
}

class _ActionDataListViewState extends State<ActionDataListView> {
  List<MyStatsModel> datas = [];
 double maxLeft = 0;
 bool showBarView = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 这里是mock数据 实际数据有了后需要移除
    for (int i = 0; i < 50; i++) {
      MyStatsModel model = MyStatsModel();
      if ([3, 5, 6, 12, 13, 14, 19, 20, 21].contains(i)) {
        model.speed = 0;
      } else {
        var random = Random();
        // 生成一个随机整数，范围从1到100
        int randomInt = random.nextInt(100);
        // 生成一个随机的双精度浮点数，范围从0.0到1.0
        model.speed = randomInt;
      }
      model.indexString = i.toString();
      datas.add(model);
      maxLeft = max(maxLeft, model.textWidth);
    }
     setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 16,right: 16),
          height: 1,
          decoration: BoxDecoration(
            color: hexStringToColor('#676767'),
            border: Border.all(color:hexStringToColor('#676767'),width: 1,style:BorderStyle.solid),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionListView(
                assetPath: 'images/connect/today_number_icon.png',
                title: 'Today',
                desc: '200'),
            ActionListView(
              assetPath: 'images/connect/totol_number_icon.png',
              title: 'Total',
              desc: '1200',
              showNext: true,
              onTap: (){
                showBarView = true;
                setState(() {

                });
              },
            ),
          ],
        ),
       showBarView ?  MyStatsBarChatView(datas: datas,maxLeft: maxLeft + 0.0) : Container(),
        Container(
          margin: EdgeInsets.only(left: 16,right: 16,top: 16),
          height: 1,
          decoration: BoxDecoration(
            color: hexStringToColor('#676767'),
            border: Border.all(color:hexStringToColor('#676767'),width: 1,style:BorderStyle.solid),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionListView(
              assetPath: 'images/connect/today_use_time.png',
              title: 'Today Use',
              desc: '600',
              unit: 'mins',
            ),
            ActionListView(
                assetPath: 'images/connect/today_cal.png',
                title: 'Calorie',
                desc: '70'),
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 16,right: 16,top: 16),
          height: 1,
          decoration: BoxDecoration(
            color: hexStringToColor('#676767'),
            border: Border.all(color:hexStringToColor('#676767'),width: 1,style:BorderStyle.solid),
          ),
        ),
      ],
    );
  }
}
