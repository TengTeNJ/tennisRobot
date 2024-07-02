import 'package:flutter/material.dart';
import 'package:tennis_robot/startPage/action_list_view.dart';

class ActionDataListView extends StatefulWidget {
  const ActionDataListView({super.key});

  @override
  State<ActionDataListView> createState() => _ActionDataListViewState();
}

class _ActionDataListViewState extends State<ActionDataListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             ActionListView(assetPath: 'images/connect/today_number_icon.png',title: 'Today',desc: '200'),
             ActionListView(assetPath: 'images/connect/totol_number_icon.png',title: 'Total',desc: '1200'),
           ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionListView(assetPath: 'images/connect/today_use_time.png',title: 'Today Use',desc: '60 min'),
            ActionListView(assetPath: 'images/connect/today_cal.png',title: 'Calorie',desc: '70'),
          ],
        ),

      ],
    );
  }
}
