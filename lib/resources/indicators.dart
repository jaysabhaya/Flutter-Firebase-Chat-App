import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_auth/SRC/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Indicators {
  ///default size is 20
  Widget indicatorWidget({
    double size = 20.0,
    Color color,
    bool istext =true,
  }) {
    final Widget indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SpinKitThreeBounce(
          color:themeColor,
          size: size,
        ),
       istext ? Text(
          'Please Wait',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ) : SizedBox(),
      ],
    );

    return indicator;
  }

  dynamic indicatorPopupWillNotPop(BuildContext context,
      {bool barrierDismissible = false}) {
    // const spinkit = SpinKitThreeBounce(
    //   color: Colors.white, //Color(0xFF303030),
    //   size: 20.0,
    // );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return null;
          },
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                Text(
                  'Please Wait',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// for hide indicator pop up
  void hideIndicator(BuildContext context) {
    Navigator.pop(context);
  }
}
