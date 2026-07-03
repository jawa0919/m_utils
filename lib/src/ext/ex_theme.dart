import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

extension ResetThemeData on ThemeData {
  Brightness get _reverseBrightness => Brightness.values[brightness.index ^ 1];
  Color get _bottomColor =>
      SystemBar.isFullScreen ? Colors.transparent : scaffoldBackgroundColor;

  ThemeData get reset => copyWith(
    appBarTheme: AppBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: brightness,
        statusBarIconBrightness: _reverseBrightness,
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: _bottomColor,
        systemNavigationBarDividerColor: _bottomColor,
        systemNavigationBarIconBrightness: _reverseBrightness,
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      shadowColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
      ),
    ),
  );
}

class SystemBar {
  SystemBar._();

  static FlutterView get _flutterView => PlatformDispatcher.instance.views.last;
  static Display get _display => _flutterView.display;

  static double get displayWidth => _display.size.width;
  static double get displayHeight => _display.size.height;

  static double get windowWidth => _flutterView.physicalSize.width;
  static double get windowHeight => _flutterView.physicalSize.height;

  static double get devicePixelRatio => _flutterView.devicePixelRatio;

  static double get statusBarHeight => _flutterView.viewPadding.top;
  static double get navigationBarHeight => _flutterView.viewPadding.bottom;

  static bool get isFullScreenWidth => displayWidth == windowWidth;
  static bool get isFullScreenHeight => displayHeight == windowHeight;
  static bool get isFullScreen => isFullScreenWidth && isFullScreenHeight;
  static bool get isPlatformDark =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  /// 获取指定scaffoldBackgroundColor颜色的SystemUiOverlayStyle
  ///
  /// 当[scaffoldBackgroundColor]为暗色时，状态栏图标为亮色，导航栏图标为暗色
  /// 当[scaffoldBackgroundColor]为亮色时，状态栏图标为暗色，导航栏图标为亮色
  static SystemUiOverlayStyle style(Color scaffoldBackgroundColor) {
    var darkest = scaffoldBackgroundColor.computeLuminance() < 0.5;
    var bh = darkest ? Brightness.dark : Brightness.light;
    var bhIcon = darkest ? Brightness.light : Brightness.dark;
    var bg = _flutterView.physicalSize.height == _display.size.height
        ? Colors.transparent
        : scaffoldBackgroundColor;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: bh,
      statusBarIconBrightness: bhIcon,
      systemStatusBarContrastEnforced: false,

      systemNavigationBarColor: bg,
      systemNavigationBarDividerColor: bg,
      systemNavigationBarIconBrightness: bhIcon,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static SystemUiOverlayStyle light(Color scaffoldBackgroundColor) {
    var bh = Brightness.light;
    var bhIcon = Brightness.dark;
    var bg = _flutterView.physicalSize.height == _display.size.height
        ? Colors.transparent
        : scaffoldBackgroundColor;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: bh,
      statusBarIconBrightness: bhIcon,
      systemStatusBarContrastEnforced: false,

      systemNavigationBarColor: bg,
      systemNavigationBarDividerColor: bg,
      systemNavigationBarIconBrightness: bhIcon,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static SystemUiOverlayStyle dark(Color scaffoldBackgroundColor) {
    var bh = Brightness.dark;
    var bhIcon = Brightness.light;
    var bg = _flutterView.physicalSize.height == _display.size.height
        ? Colors.transparent
        : scaffoldBackgroundColor;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: bh,
      statusBarIconBrightness: bhIcon,
      systemStatusBarContrastEnforced: false,

      systemNavigationBarColor: bg,
      systemNavigationBarDividerColor: bg,
      systemNavigationBarIconBrightness: bhIcon,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
