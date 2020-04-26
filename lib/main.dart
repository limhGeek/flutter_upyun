import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterupyun/upyun_http.dart';
import 'package:flutterupyun/toast_utils.dart';
import 'package:flutterupyun/upyun_utils.dart';
import 'package:fsuper/fsuper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        title: '上传文件',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: '上传文件'),
        navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //选择图片相关
  double picWidth = 80;
  String encryp = "";
  File imageFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FSuper(
            margin: EdgeInsets.only(left: 20),
            height: picWidth,
            width: double.infinity,
            child1: null == imageFile
                ? Container(
                    width: picWidth,
                    height: picWidth,
                    color: Color(0xffEEEEEE),
                  )
                : Image.file(
                    imageFile,
                    width: picWidth,
                    height: picWidth,
                    fit: BoxFit.cover,
                  ),
            child1Alignment: Alignment.centerLeft,
            child2: Container(
              width: picWidth,
              height: picWidth,
              color: Color(0xffEEEEEE),
              child: Icon(
                Icons.add,
                color: Color(0xff999999),
              ),
            ),
            child2Margin: EdgeInsets.only(left: 20 + picWidth),
            child2Alignment: Alignment.centerLeft,
            onChild2Click: () {
              setState(() {
                imageFile = null;
              });
              _openAlbum();
            },
          ),
          FSuper(
            text: "上传文件",
            backgroundColor: Theme.of(context).accentColor,
            corner: Corner.all(20),
            height: 40,
            textAlignment: Alignment.center,
            textSize: 16,
            textColor: Colors.white,
            width: double.infinity,
            margin: EdgeInsets.only(left: 40, right: 40, top: 20),
            shadowBlur: 5,
            shadowColor: Theme.of(context).accentColor,
            onClick: () {
              print("开始上传");
              _upload();
            },
          ),
          Container(
            width: double.infinity,
            child: Text(encryp),
          )
        ],
      ),
    );
  }

  void _upload() {
    CancelFunc cancelFunc = Toast.loading("上传中...");
    UHttp.upload("/", imageFile, successCallBack: (data) {
      cancelFunc();
    }, errorCallBack: (error) {
      Toast.show(error);
      cancelFunc();
    });
  }

  ///打开相册
  Future _openAlbum() async {
    print('打开相册');
    AssetPicker.pickAssets(context,
            maxAssets: 1, themeColor: Theme.of(context).accentColor)
        .then((List<AssetEntity> assets) async {
      File tmp = await assets.first.file;
      setState(() {
        imageFile = tmp;
      });
    });
  }
}
