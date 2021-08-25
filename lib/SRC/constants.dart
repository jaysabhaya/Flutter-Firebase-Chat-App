import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'dart:ui';
import 'hexColor.dart';

final themeColor = HexColor('#ad1a7f');
final colorPrimaryDark = HexColor('#6d0094');
final colorAccent = HexColor('#ff2068');
final colorAccentSecondary = HexColor('#6d0094');
final viewBg = HexColor('#f8f8f8');
final lblValue = HexColor('#222222');

final themeColor2 = Color(0xff203152);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);


class ToastMSG {
  ToastMSG(
    BuildContext context,
    String textMSG,
  ) {
    showToastWidget(
      Padding(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: themeColor.withOpacity(0.5) //Color(0xFF00D5C5),
              ),
          width: textMSG.toString().length * 12.0,
          height: 50.0,
          child: Center(
              child: Text(
            textMSG,
            style: TextStyle(color: Colors.white, fontSize: 15.0),
          )),
        ),
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 48),
      ),
      context: context,
      position: StyledToastPosition.bottom,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastLinearToSlowEaseIn,
      movingOnWindowChange: true,
    );
  }
}