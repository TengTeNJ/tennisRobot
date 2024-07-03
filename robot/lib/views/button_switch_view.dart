import 'package:flutter/material.dart';
import 'package:tennis_robot/constant/constants.dart';

class ButtonSwitchView extends StatefulWidget {
  String leftTitle;
  String rightTitle;
  Function? selectItem;

  ButtonSwitchView({required this.leftTitle, required this.rightTitle});

  @override
  State<ButtonSwitchView> createState() => _ButtonSwitchViewState();
}

class _ButtonSwitchViewState extends State<ButtonSwitchView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (_currentIndex == 0) {
              return;
            }
            setState(() {
              _currentIndex = 0;
            });
            if (widget.selectItem != null) {
              widget.selectItem!(_currentIndex);
            }
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
                color: _currentIndex == 0
                    ? Constants.baseStyleColor
                    : Constants.selectModelBgColor,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Constants.customTextWidget(widget.leftTitle, 15,
                  _currentIndex == 0 ? '#ffffff' : '#9C9C9C',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        GestureDetector(
          onTap: () {
            if (_currentIndex == 1) {
              return;
            }
            setState(() {
              _currentIndex = 1;
            });
            if (widget.selectItem != null) {
              widget.selectItem!(_currentIndex);
            }
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
                color: _currentIndex == 1
                    ? Constants.baseStyleColor
                    : Constants.selectModelBgColor,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Constants.customTextWidget(widget.rightTitle, 15,
                  _currentIndex == 1 ? '#ffffff' : '#9C9C9C',
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}
