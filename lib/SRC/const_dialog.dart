import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  const CustomDialogBox(
      {Key key,
      this.title,
      this.descriptions,
      @required this.activeButtonOne,
      @required this.activeButtonTwo,
      this.buttonOneText,
      this.buttonTwoText,
      this.onPressedOne,
      this.onPressedTwo,
      this.img})
      : super(key: key);

  final String title, descriptions, buttonOneText, buttonTwoText;
  final bool activeButtonOne, activeButtonTwo;
  final Function onPressedOne, onPressedTwo;
  final Image img;

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  static const double padding = 20;
  // static const double avatarRadius = 45;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Container contentBox(context) {
    return Container(
      padding: EdgeInsets.only(
          left: padding, top: padding, right: padding, bottom: padding),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 5), blurRadius: 5),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 15),
          Text(
            widget.descriptions,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          widget.activeButtonOne == false && widget.activeButtonTwo == false
              ? SizedBox(height: 10)
              : SizedBox(height: 20),
          widget.activeButtonOne == false && widget.activeButtonTwo == false
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.activeButtonOne
                        ? Expanded(
                            child: FlatButton(
                              onPressed: widget.onPressedOne,
                              child: Text(
                                widget.buttonOneText,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        : SizedBox(),
                    widget.activeButtonTwo
                        ? Expanded(
                            child: FlatButton(
                              onPressed: widget.onPressedTwo,
                              child: Text(
                                widget.buttonTwoText,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
        ],
      ),
    );
  }
}
