import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterupyun/log_util.dart';
import 'package:flutterupyun/upyun_utils.dart';

class UHttp {
//  String auth = UpYunUtils.getSign("PUT", uri, date, policy, md5);
  static Dio _dio;

  static Dio createInstance() {
    if (_dio == null) {
      _dio = Dio();
      _dio.options.baseUrl = "https://v0.api.upyun.com";
      _dio.options.receiveTimeout = 30000;
      _dio.options.connectTimeout = 30000;
    }
    return _dio;
  }

  static Future upload(String url, List<File> files,
      {Function successCallBack, Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;
    Response response;
    if (null == files || files.isEmpty) {
      _handError(errorCallBack, errorMsg: "文件不能为空");
      return;
    }
    try {
      _dio = createInstance();
      String date = UpYunUtils.getRfc1123Time();
      _dio.options.headers.remove("content-type");
      _dio.options.headers["Authorization"] =
          UpYunUtils.getSign("PUT", url, date, "", "");
      _dio.options.headers["Date"] = "$date";
      String path = files[0].path;
      var name = path.substring(path.lastIndexOf("/") + 1, path.length);
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name)
      });

//      for (var i = 0; i < files.length; i++) {
//        File file = files[i];
//        String path = file.path;
//        var name = path.substring(path.lastIndexOf("/") + 1, path.length);
//        formData.files.add(
//            MapEntry("file", MultipartFile.fromFileSync(path, filename: name)));
//      }
      _dio.options.headers["Content-Length"] = formData.length;
      _dio.options.headers["Content-Type"] = "image/jpg";
      LogUtil.v("===============================================", tag: "Http");
      LogUtil.v("请求地址：${_dio.options.baseUrl}$url", tag: "Http");
      LogUtil.v("请求头：${_dio.options.headers}", tag: "Http");
      response = await _dio.put(url, data: formData);
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
      LogUtil.v("===============================================", tag: "Http");
    } on DioError catch (exception) {
      _handError(errorCallBack, error: exception);
    } catch (e) {
      LogUtil.e("未知异常:${e.toString()}", tag: "Http");
      _handError(errorCallBack, errorMsg: "请求出错");
    }
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
    LogUtil.v("请求出错：${error.toString()}",tag: "Http");
    LogUtil.v("===============================================",tag: "Http");
  }
}
