import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tennis_robot/models/pickup_ball_model.dart';
import 'package:tennis_robot/startPage/action_list_view.dart';
import 'package:tennis_robot/utils/color.dart';
import 'package:tennis_robot/startPage/data_bar_view.dart';
import '../models/my_status_model.dart';
import 'package:tennis_robot/utils/data_base.dart';
import 'package:tennis_robot/constant/constants.dart';
import '../utils/string_util.dart';

class ActionDataListView extends StatefulWidget {
  const ActionDataListView({super.key});
  @override
  State<ActionDataListView> createState() => _ActionDataListViewState();
}

class _ActionDataListViewState extends State<ActionDataListView> {
  List<MyStatsModel> datas = [];
  double maxLeft = 0;
  bool showBarView = false;
  String todayCount = '0'; //今天捡球数
  int totalCount = 0; // 总的捡球数
  int todayCal = 0; // 今日消耗卡路里
  int maxCount = 0; // 最大进球数
  int useMinutes = 0;// 今日使用分钟数

  //计算卡路里消耗 今天捡球数 总的捡球数
  Future<void> calculateCalorie() async {
    var second = await DataBaseHelper().fetchData(); // 今日使用时间
    useMinutes = (second / 60).round();
    // 1个小时能打70个网球
    // 网球卡路里计算公式  CBT = TT/60 * 650 * BW/150; CBT是消耗的卡路里数，TT是打网球的总时间（分钟），BW是体重
    var weight = 120; // 体重
    final _list  = await DataBaseHelper().getData(kDataBaseTableName);
    print('${_list}');
    _list.forEach((element){
      setState(() {
        totalCount += int.parse(element.pickupBallNumber);
        var todayTime = StringUtil.currentTimeString();
        if (todayTime.contains(element.time)) {
          todayCount = element.pickupBallNumber;
          var sportMinute = int.parse(todayCount) * 60 / 70;
          var cal = sportMinute / 60 * 650 * weight/150;
          todayCal = cal.round();
          print('今天消耗的卡路里${todayCal}');
        }
      });
    });
  }

  // 组装图标数据
  Future<void> chartData() async {
    final _list = await DataBaseHelper().getData(kDataBaseTableName);
    for (int i = 0 ; i < _list.length ; i++) {
      MyStatsModel model = MyStatsModel();
      model.speed = int.parse(_list[i].pickupBallNumber);
      model.indexString = i.toString();
      datas.add(model);
      maxLeft = max(maxLeft, model.textWidth);
    }
    maxCount = getMaxValue(datas);
  }

  int getMaxValue(List<MyStatsModel> items) {
    return items.reduce((max, item) => max.speed > item.speed ? max : item).speed;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateCalorie(); // 卡片数据
    chartData(); // 图表数据

    // 这里是mock数据 实际数据有了后需要移除
    // for (int i = 0; i < 10; i++) {
    //   MyStatsModel model = MyStatsModel();
    //   if ([3, 5, 6].contains(i)) {
    //     model.speed = 0;
    //   } else {
    //     var random = Random();
    //     // 生成一个随机整数，范围从1到100
    //     int randomInt = random.nextInt(100);
    //     // 生成一个随机的双精度浮点数，范围从0.0到1.0
    //     print('随机数${randomInt}');
    //     model.speed = randomInt;
    //   }
    //   model.indexString = i.toString();
    //   datas.add(model);
    //   maxLeft = max(maxLeft, model.textWidth);
    // }
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
                desc: todayCount),
            ActionListView(
              assetPath: 'images/connect/totol_number_icon.png',
              title: 'Total',
              desc: totalCount.toString(),
              showNext: true,
              onTap: (){
                showBarView = true;
                setState(() {

                });
              },
            ),
          ],
        ),
       showBarView ?  MyStatsBarChatView(datas: datas,maxLeft: maxLeft + 0.0,maxCount: maxCount,) : Container(),
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
              desc: '${useMinutes}',
              unit: 'mins',
            ),
            ActionListView(
                assetPath: 'images/connect/today_cal.png',
                title: 'Calorie',
                desc: todayCal.toString()),
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
