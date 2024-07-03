import 'package:flutter/material.dart';
import '../constant/constants.dart';

/// 功能切换view
class RobotFunctionSwitchView extends StatefulWidget {
  Function? resetModeClick;
  Function? trainModeClick;

  RobotFunctionSwitchView({this.resetModeClick, this.trainModeClick});

  @override
  State<RobotFunctionSwitchView> createState() => _RobotFunctionSwitchViewState();
}

class _RobotFunctionSwitchViewState extends State<RobotFunctionSwitchView> {
  Color _shutBGColor = Constants.selectedModelOrangeBgColor;
  Color _resetBGColor = Constants.selectModelBgColor;
  Color _trainBGColor = Constants.selectModelBgColor;
  Color _controlBGColor = Constants.selectModelBgColor;

  var _shutdownPicName = 'images/resetmode/function_shutdown_select.png';
  var _resetPicName = 'images/resetmode/function_reset_icon.png';
  var _trainPicName = 'images/resetmode/function_train_icon.png';
  var _controlPicName = 'images/resetmode/function_control_icon.png';


  void _actionBtnClick(int index) {
      setState(() {
         if (index == 0) {
            _shutBGColor = Constants.selectedModelOrangeBgColor;
            _resetBGColor = Constants.selectModelBgColor;
            _trainBGColor = Constants.selectModelBgColor;
            _controlBGColor = Constants.selectModelBgColor;
            _shutdownPicName = 'images/resetmode/function_shutdown_select.png';
            _resetPicName = 'images/resetmode/function_reset_icon.png';
            _trainPicName = 'images/resetmode/function_train_icon.png';
            _controlPicName = 'images/resetmode/function_control_icon.png';
         } else if (index == 1){
           _shutBGColor = Constants.selectModelBgColor;
           _resetBGColor = Constants.selectedModelOrangeBgColor;
           _trainBGColor = Constants.selectModelBgColor;
           _controlBGColor = Constants.selectModelBgColor;
           _shutdownPicName = 'images/resetmode/function_shutdown_icon.png';
           _resetPicName = 'images/resetmode/function_reset_select.png';
           _trainPicName = 'images/resetmode/function_train_icon.png';
           _controlPicName = 'images/resetmode/function_control_icon.png';
         } else if (index == 2){
           _shutBGColor = Constants.selectModelBgColor;
           _resetBGColor = Constants.selectModelBgColor;
           _trainBGColor = Constants.selectedModelOrangeBgColor;
           _controlBGColor = Constants.selectModelBgColor;
           _shutdownPicName = 'images/resetmode/function_shutdown_icon.png';
           _resetPicName = 'images/resetmode/function_reset_icon.png';
           _trainPicName = 'images/resetmode/function_train_select.png';
           _controlPicName = 'images/resetmode/function_control_icon.png';
         } else {
           _shutBGColor = Constants.selectModelBgColor;
           _resetBGColor = Constants.selectModelBgColor;
           _trainBGColor = Constants.selectModelBgColor;
           _controlBGColor = Constants.selectedModelOrangeBgColor;
           _shutdownPicName = 'images/resetmode/function_shutdown_icon.png';
           _resetPicName = 'images/resetmode/function_reset_icon.png';
           _trainPicName = 'images/resetmode/function_train_icon.png';
           _controlPicName = 'images/resetmode/function_control_select.png';
         }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       width: Constants.screenWidth(context),
       height:60 ,

       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         // mainAxisSize: MainAxisSize.max,
         children: [
           GestureDetector(onTap: (){
             print('shutdown');
             _actionBtnClick(0);
           },
             child:Container(
             // decoration: BoxDecoration(
             //   borderRadius: BorderRadius.circular(8),
             // ),

             margin: EdgeInsets.only(left: 28),
             width: 60,
             height: 60,
             child: Stack(

               children: [
                 Container(
                   width: 60,
                   height: 60,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4),
                     color: Constants.selectModelBgColor ,
                   ),
                 ),
                 Positioned(
                   left: 3,
                   top: 3,
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(4),
                       color: _shutBGColor,
                     ),
                     width: 54,
                     height: 54,
                     child: Image(image: AssetImage(_shutdownPicName),),
                   ),
                 ),
               ],
             ),
           ),),

           GestureDetector(onTap: (){
             if (widget.resetModeClick != null) {
               widget.resetModeClick!();
             }
             print('reset');
             _actionBtnClick(1);

           },child: Container(
             margin: EdgeInsets.only(left: 13),
             width: 60,
             height: 60,

             child: Stack(
               children: [
                 Container(
                   height: 60,
                   width: 60,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4),
                     color:  Constants.selectModelBgColor,
                   ),
                 ),
                 Positioned(
                   left: 3,
                   top: 3,
                   child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(4),
                         color: _resetBGColor,

                       ),
                       width: 54,
                       height: 54,
                       child:Center(
                         child: Container(
                           child: Image(image: AssetImage(_resetPicName),width: 23,fit: BoxFit.fitWidth,),

                         ),
                       )
                   ),
                 ),
               ],
             ),
           ),),

           GestureDetector(onTap: (){
             print('train');
             if (widget.trainModeClick != null) {
               widget.trainModeClick!();
             }

             _actionBtnClick(2);

           },child: Container(
             margin: EdgeInsets.only(left: 13),
             width: 60,
             height: 60,
             child: Stack(
               children: [
                 Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4),
                     color:  Constants.selectModelBgColor,
                   ),
                   height: 60,
                   width: 60,
                 ),
                 Positioned(
                   left: 3,
                   top: 3,
                   child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(4),
                         color: _trainBGColor,

                       ),
                       width: 54,
                       height: 54,
                       child:Center(
                         child: Container(
                           child: Image(image: AssetImage(_trainPicName),width: 23,fit: BoxFit.fitWidth,),

                         ),
                       )
                   ),
                 ),
               ],
             ),
           ),),

           GestureDetector(onTap: () {
             print('control');
             _actionBtnClick(3);

           },child: Container(
             margin: EdgeInsets.only(left: 13),
             width: 60,
             height: 60,
             child: Stack(
               children: [
                 Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4),
                     color:  Constants.selectModelBgColor ,
                   ),
                   height: 60,
                   width: 60,
                 ),
                 Positioned(
                   left: 3,
                   top: 3,
                   child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(4),
                         color: _controlBGColor,

                       ),
                       width: 54,
                       height: 54,
                       child:Center(
                         child: Container(
                           child: Image(image: AssetImage(_controlPicName),width: 23,fit: BoxFit.fitWidth,),

                         ),
                       )
                   ),
                 ),
               ],
             ),
           ),),

         ],
       ),
    );
  }
}
