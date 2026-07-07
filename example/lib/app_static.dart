import 'package:flutter/material.dart';

class AppStatic {
  AppStatic._();
  // 适合UI的尺寸
  static const designWidth = 1080.0;
  static const designHeight = 2340.0;
  static final designLandscape = designWidth < designHeight;
  // App Store id
  static const String appStoreId = '';
  // 获取App Store更新信息
  static const String appStoreLookup = 'https://itunes.apple.com/cn/lookup?id=';
  // 用户协议url
  static const String agreementUrl = 'https://flutter.cn';
  // 隐私政策url
  static const String privacyUrl = 'https://flutter.cn';
  // icp备案号
  static const String icpNumber = 'AAA-BBB-CCC';
  // icp备案号查询链接
  static const String icpQueryUrl = 'https://beian.miit.gov.cn/';
  // 版权标志
  static const String copyrightCode = 'Copyright © 2006-2026 flutter.cn';

  /// 服务器列表
  static const serverList = [
    {
      'env': 'prod',
      'apiHost': 'https://flutter.cn',
      'h5Host': 'https://flutter.cn',
    },
    {
      'env': 'test',
      'apiHost': 'https://flutter.cn',
      'h5Host': 'https://flutter.cn',
    },
    {
      'env': 'dev',
      'apiHost': 'https://flutter.cn',
      'h5Host': 'https://flutter.cn',
    },
    {'env': 'custom', 'apiHost': null, 'h5Host': null},
  ];

  /// 主题色
  static const primaryColor = Color(0xFF5856D7);

  /// 真白颜色
  static const trueBlack = Color(0xFF000000);

  /// 真黑颜色
  static const trueWhite = Color(0xFFFFFFFF);

  /// 真透明颜色
  static const trueTransparent = Color(0x00000000);

  static final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor)
      .copyWith(
        primary: primaryColor,

        secondary: Color(0xFF8A88E0),

        error: Color(0xFFD54941),

        surface: Color(0xFFF3F3F3),
        onSurface: Color.fromRGBO(0, 0, 0, 0.9),

        surfaceContainerHighest: Color.fromRGBO(0, 0, 0, 0.9),
        surfaceContainerHigh: Color.fromRGBO(0, 0, 0, 0.9),
        surfaceContainer: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFFFFFFF),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        onSurfaceVariant: Color.fromRGBO(0, 0, 0, 0.6),

        scrim: Color.fromRGBO(0, 0, 0, 0.26),

        outline: Color(0xFFC5C5C5),
        outlineVariant: Color(0xFFDCDCDC),
      );
}
