import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;
import 'package:share_plus/share_plus.dart';

class ShareUtil {
  ShareUtil._();

  /// 分享文本
  static Future<bool> text(String text) async {
    final params = ShareParams(text: text);
    return await SharePlus.instance
        .share(params)
        .then((v) => v.status == ShareResultStatus.success);
  }

  /// 分享文件
  static Future<bool> file(String text, String filePath) async {
    final params = ShareParams(text: text, files: [XFile(filePath)]);
    return await SharePlus.instance
        .share(params)
        .then((v) => v.status == ShareResultStatus.success);
  }

  /// 系统浏览器打开网页
  static Future<bool> openSystemBrowser(String url) async {
    if (!url.startsWith('http')) throw Exception('url must start with http');
    return await launchUrlString(url);
  }

  /// 打电话
  static Future<bool> callPhone(String phoneNumber) async {
    if (!phoneNumber.startsWith('tel:')) phoneNumber = 'tel:$phoneNumber';
    return await launchUrlString(phoneNumber);
  }

  /// 发短信
  static Future<bool> sendSms(String phoneNumber, [String body = '']) async {
    if (!phoneNumber.startsWith('sms:')) phoneNumber = 'sms:$phoneNumber';
    phoneNumber += Platform.isIOS ? '&' : '?';
    phoneNumber += 'body=$body';
    return await launchUrlString(phoneNumber);
  }

  /// 发送邮件
  static Future<bool> sendEmail(
    String email, [
    String subject = '',
    String body = '',
  ]) async {
    if (!email.contains('@')) throw Exception('email must contain @');
    email += '?subject=$subject&body=$body';
    return await launchUrlString(email);
  }
}
