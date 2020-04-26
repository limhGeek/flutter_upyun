import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterupyun/log_util.dart';
import 'package:flutterupyun/upyun_utils.dart';

class UHttp {
  static Dio _dio;

  static Dio createInstance() {
    if (_dio == null) {
      _dio = Dio();
      _dio.options.baseUrl = UpUtils.UpYun_URL;
      _dio.options.receiveTimeout = 30000;
      _dio.options.connectTimeout = 30000;
    }
    return _dio;
  }

  static Future upload(String url, File file,
      {Function successCallBack, Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;
    Response response;
    if (null == file) {
      _handError(errorCallBack, errorMsg: "文件不能为空");
      return;
    }
    try {
      _dio = createInstance();
      DateTime dateTime = DateTime.now().toUtc();
      String date = UpUtils.getRfc1123Time(dateTime);

      String path = file.path;
      var name = path.substring(path.lastIndexOf("/") + 1, path.length);
      var sufix = name.substring(name.lastIndexOf(".") + 1);

      ///计算policy参数
      Map<String, String> map = Map();
      map["bucket"] = UpUtils.UpYun_BUCKET;
      map["date"] = "$date";
      map["expiration"] = UpUtils.getExpiration(dateTime);
      map["save-key"] = "$url/${UpUtils.getUUID()}.$sufix";

      String policy = UpUtils.getPolicy(map);
      String sign =
          UpUtils.getSign("POST", "/${UpUtils.UpYun_BUCKET}", date, policy, "");

      ///封装body
      List<MapEntry<String, String>> params = List();
      params.add(MapEntry("policy", policy));
      params.add(MapEntry("authorization", sign));
      params.add(MapEntry("date", date));

      ///添加文件
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name),
      });

      formData.fields.addAll(params);
      LogUtil.v("===============================================", tag: "Http");
      response = await _dio.post("/${UpUtils.UpYun_BUCKET}", data: formData);
      statusCode = response.statusCode;
      if (200 != statusCode) {
        LogUtil.v("请求出错：${response.statusMessage}");
        errorMsg = "$statusCode  ${response.statusMessage}";
        _handError(errorCallBack, errorMsg: errorMsg);
        return;
      } else {
        successCallBack(json.encode(response.data));
      }
      LogUtil.v("请求响应：${response.data}", tag: "Http");
    } on DioError catch (exception) {
      _handError(errorCallBack, error: exception);
    } catch (e) {
      LogUtil.e("未知异常:${e.toString()}", tag: "Http");
      _handError(errorCallBack, errorMsg: "请求出错");
    }
    LogUtil.v("===============================================", tag: "Http");
  }

  static void _handError(Function errorCallback,
      {DioError error, String errorMsg}) {
    String message = null != error ? error.message : errorMsg;
    if (null != error) {
      switch (error.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          message = "网络连接超时，请检查网络设置";
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          message = "服务器异常，请稍后重试！";
          break;
        case DioErrorType.SEND_TIMEOUT:
          message = "网络连接超时，请检查网络设置";
          break;
        case DioErrorType.RESPONSE:
          message = "服务器异常，请稍后重试！";
          break;
        case DioErrorType.CANCEL:
          message = "请求已被取消，请重新请求";
          break;
        case DioErrorType.DEFAULT:
          message = "网络异常，请稍后重试！";
          break;
      }
    }
    if (null != errorCallback) {
      errorCallback(message);
    }
    LogUtil.v("请求出错：${error.toString()}", tag: "Http");
    LogUtil.v("===============================================", tag: "Http");
  }
}
