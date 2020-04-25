import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterupyun/UHttp.dart';
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
  List<Widget> list;
  List<File> listPics;
  List<String> fileList;
  double picWidth = 80;
  String encryp = "";

  @override
  void initState() {
    super.initState();
    list = List<Widget>()..add(_buildPicButton());
    listPics = List<File>();
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
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            width: double.infinity,
            child: Wrap(
              children: list,
              spacing: 10,
              runSpacing: 10,
            ),
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
    UHttp.upload("/images-topic/topic", listPics, successCallBack: (data) {
      cancelFunc();
    }, errorCallBack: (error) {
      Toast.show(error);
      cancelFunc();
    });
  }

  ///构建添加图片按钮
  Widget _buildPicButton() {
    return GestureDetector(
      onTap: () {
        if (listPics.length >= 3) {
          Toast.show("最多可选3张图片");
          return;
        }
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (builder) {
              return _choicePic();
            });
      },
      child: Container(
        width: picWidth,
        height: picWidth,
        color: Color(0xffEEEEEE),
        child: Icon(
          Icons.add,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  ///选择图片对话框
  Widget _choicePic() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
          width: double.maxFinite,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: Column(children: <Widget>[
            FlatButton(onPressed: _openAlbum, child: Text('从相册中选择'))
          ])),
      Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ))
    ]);
  }

  ///打开相册
  Future _openAlbum() async {
    print('打开相册');
    Navigator.pop(context);
    AssetPicker.pickAssets(context,
            maxAssets: 3 - listPics.length,
            themeColor: Theme.of(context).accentColor)
        .then((List<AssetEntity> assets) {
      assets.forEach((AssetEntity asset) async {
        File image = (await asset.file);
        listPics.add(image);
        setState(() {
          list.insert(list.length - 1, _buildPhoto(image));
        });
      });
    });
  }

  ///构建图片
  Widget _buildPhoto(File image) {
    return Stack(
        overflow: Overflow.visible,
        alignment: Alignment(0.9, -0.9),
        children: <Widget>[
          Container(
            width: picWidth,
            height: picWidth,
            child: Image.file(
              image,
              width: picWidth,
              height: picWidth,
              fit: BoxFit.cover,
            ),
          ),
          GestureDetector(
            onTap: () {
              var index = listPics.indexOf(image);
              setState(() {
                listPics.removeAt(index);
                list.removeAt(index);
              });
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  color: Color(0x7f000000),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 12,
              ),
            ),
          )
        ]);
  }
}
