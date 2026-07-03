import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class CryptoUtil {
  CryptoUtil._();

  /// md5
  static String md5Encoder(String p) {
    final date = utf8.encode(p);
    final digest = md5.convert(date);
    String pMD5 = digest.toString();
    return pMD5;
  }

  /// she1
  static String she1Encoder(String p) {
    final date = utf8.encode(p);
    final digest = sha1.convert(date);
    String pSHA1 = digest.toString();
    return pSHA1;
  }

  /// she256
  static String she256Encoder(String p) {
    final date = utf8.encode(p);
    final digest = sha256.convert(date);
    String pSHA1 = digest.toString();
    return pSHA1;
  }

  /// rsa加密
  static String rsaEncoder(String p, String key) {
    final publicKey = RSAKeyParser().parse(key);
    final encrypter = Encrypter(RSA(publicKey: publicKey as dynamic));
    final encrypted = encrypter.encrypt(p);
    return encrypted.base64;
  }

  /// 简单base64混淆-这是自己写一种加密逻辑，对用户名密码进行加密存储
  ///
  /// 逻辑: 一组字符串，用空格补齐相同长度，竖向拼和,base64转5-9次，拼接列表长度，转换次数，和转换后数据
  static String e(List<String> encoderList) {
    if (encoderList.length > 9) throw ('List.length too long');
    int length = encoderList.length;
    int maxLen = encoderList.fold<int>(0, (p, e) => max(p, e.length));
    encoderList = encoderList.map((e) => e.padRight(maxLen)).toList();
    String ee = '';
    for (var i = 0; i < maxLen; i++) {
      for (var j = 0; j < length; j++) {
        ee += encoderList[j][i];
      }
    }
    int diff = Random().nextInt(4) + 5;
    for (var i = 0; i < diff; i++) {
      ee = base64Encode(utf8.encode(ee));
    }
    return '$length$diff$ee';
  }

  /// 简单base64解密
  static List<String> d(String str) {
    int length = int.parse(str.substring(0, 1));
    int diff = int.parse(str.substring(1, 2));
    String e = str.substring(2);
    for (var i = 0; i < diff; i++) {
      e = String.fromCharCodes(base64Decode(e));
    }
    List<String> s = List.generate(length, (index) => '');
    for (int i = 0; i < e.length; i++) {
      s[i % length] += e[i];
    }
    return s.map((e) => e.trim()).toList();
  }
}
