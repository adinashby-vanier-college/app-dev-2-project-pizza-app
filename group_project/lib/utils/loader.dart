import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:group_project/utils/colors.dart';

final GlobalKey<State>? _progressLoader = GlobalKey<State>();

class CommonUtils {
  static Future<void> showProgressLoading(BuildContext context) async {
    if (_progressLoader!.currentContext != null) {
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            elevation: 0,
            key: _progressLoader,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: LoadingAnimationWidget.beat(
                  color: AppColor.primaryColor,
                  size: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideProgressLoading() {
    if (_progressLoader!.currentContext != null) {
      Navigator.of(_progressLoader!.currentContext!, rootNavigator: true).pop();
    }
  }
}
