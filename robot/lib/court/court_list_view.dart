import 'package:flutter/material.dart';
import 'package:tennis_robot/court/court_list_item_view.dart';
import 'package:tennis_robot/models/CourtModel.dart';

import '../Constant/constants.dart';
import '../utils/data_base.dart';


class CourtListView extends StatefulWidget {
  List<Courtmodel> datas;

  CourtListView({required this.datas});

  @override
  State<CourtListView> createState() => _CourtListViewState();
}

class _CourtListViewState extends State<CourtListView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalCourtData();
  }
  void getLocalCourtData() async{
    final _list  = await DataBaseHelper().getCourtData(kDataBaseCourtTableName);
    widget.datas = _list as List<Courtmodel>;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index){
          return CourtListItemView(model: widget.datas[index]);
        }, separatorBuilder:(context, index) => SizedBox(height: 10,)
        , itemCount: widget.datas.length);
  }
}
