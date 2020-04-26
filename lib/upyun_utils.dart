import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutterupyun/log_util.dart';
import 'package:intl/intl.dart';

class UpUtils {
  ///操作员名称
  static const UpYUN_KEY = "limh";

  ///操作员密钥
  static const UpYUN_SECRET = "x07idNUQwaCAqSmSsTpGB2cBnCfpRgzK";
//  static const UpYUN_SECRET = "操作员密码";

  ///服务名称
  static const UpYun_BUCKET = "chipapp";

  ///请求API接口地址，
  static const UpYun_URL = "https://v0.api.upyun.com";

  ///生成又拍云签名
  static String getSign(
      String method, String uri, String date, String policy, String md5) {
    String value = method + "&" + uri + "&" + date;
    if (policy != "") {
      value = value + "&" + policy;
    }
    if (md5 != "") {
      value = value + "&" + md5;
    }
    List<int> hmac = hashHmac(value, getMd5(UpYUN_SECRET));
    String sign = base64Encode(hmac);
    return "UPYUN " + UpYUN_KEY + ":" + sign;
  }

  ///Md5加密
  static String getMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  ///HmacSha1加密
  static List<int> hashHmac(String data, String key) {
    var hmac = Hmac(sha1, Utf8Encoder().convert(key));
    return hmac.convert(Utf8Encoder().convert(data)).bytes;
  }

  ///Policy签名算法
  static String getPolicy(Map data) {
    return base64Encode(Utf8Encoder().convert(json.encode(data)));
  }

  ///生成格林威治时间
  static String getRfc1123Time(DateTime dateTime) {
    String time =
        DateFormat.E().add_d().add_yMMM().add_Hms().format(dateTime.toUtc());
    return time.replaceFirst(" ", ", ") + " GMT";
  }

  ///生成签名有效期（单位:分钟），默认30分钟
  static String getExpiration(DateTime dateTime, {int second = 30}) {
    return "${(dateTime.toUtc().millisecondsSinceEpoch + second * 60 * 1000) ~/ 1000}";
  }

  ///生成16位随机文件名
  static String getUUID() {
    String alphabet = 'QW5ER1TYUIO2PA0S8DFG3HJ4KL6ZXCV7BN9M';
    int strlenght = 16;
    String left = '';
    for (var i = 0; i < strlenght; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }
}
