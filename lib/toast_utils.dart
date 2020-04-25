import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class Toast {
  static void show(String msg) {
    if (null == msg || "" == msg) {
      return;
    }
    BotToast.showText(
      text: msg,
      contentColor: Colors.black87,
    );
  }

  static CancelFunc loading(String msg) {
    if (null == msg) {
      msg = "加载中...";
    }
    return BotToast.showCustomLoading(
        backgroundColor: Colors.black54,
        backButtonBehavior: BackButtonBehavior.close,
        toastBuilder: (ca) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: 120,
            width: 120,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                Padding(
                  child: Text(
                    msg,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                ),
              ],
            ),
          );
        });
  }
}
