import 'package:flutter/material.dart';
import 'package:tennis_robot/court/court_list_item_view.dart';
import 'package:tennis_robot/models/CourtModel.dart';


class CourtListView extends StatefulWidget {
  List<Courtmodel> datas;

  CourtListView({required this.datas});

  @override
  State<CourtListView> createState() => _CourtListViewState();
}

class _CourtListViewState extends State<CourtListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index){
          return CourtListItemView(model: widget.datas[index]);
        }, separatorBuilder:(context, index) => SizedBox(height: 10,)
        , itemCount: widget.datas.length);
  }
}
