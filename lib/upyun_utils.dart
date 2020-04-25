import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class UpYunUtils {
  static const UpYUN_KEY = "limh";
  static const UpYUN_SECRET = "keRaOuxnaGXFRBsXogB401sU5DznmmRS";

  static String getSign(
      String method, String uri, String date, String policy, String md5) {
    String value = method + "&" + uri + "&" + date;
    if (policy != "") {
      value = value + "&" + policy;
    }
    if (md5 != "") {
      value = value + "&" + md5;
    }
    print("value=$value");
    List<int> hmac = hashHmac(value, getMd5(UpYUN_SECRET));
    String sign = base64Encode(hmac);
    return "UPYUN " + UpYUN_KEY + ":" + sign;
  }

  static String getMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static List<int> hashHmac(String data, String key) {
    var hmac = Hmac(sha1, Utf8Encoder().convert(key));
    return hmac.convert(Utf8Encoder().convert(data)).bytes;
  }

  static String getRfc1123Time() {
    String time = DateFormat.E()
        .add_d()
        .add_yMMM()
        .add_Hms()
        .format(DateTime.now().toUtc());
    return time.replaceFirst(" ", ", ") + " GMT";
  }
}
