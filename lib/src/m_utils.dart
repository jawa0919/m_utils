import 'dart:io' show Directory, Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, debugPrint;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MUtils {
  MUtils._();
  static bool get isProduct => bool.fromEnvironment('dart.vm.product');
  static bool get isWeb => bool.fromEnvironment('dart.library.js_util');
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isChina => Platform.localeName.contains('zh');

  // 本地存储和文件夹路径
  static late SharedPreferences pref;
  static String docsDir = Directory.current.path;
  static String tempDir = Directory.systemTemp.path;

  // 设备信息
  static Map<String, dynamic>? _dMap;
  static Map<String, dynamic>? get deviceInfo => _dMap;
  static String get devicePlatform => Platform.operatingSystem;
  static String get deviceVersion =>
      _dMap?['version']?['sdkInt']?.toString() ??
      _dMap?['systemVersion'] ??
      '0';
  static String get _brand => _dMap?['brand'] ?? _dMap?['model'] ?? 'null';
  static String get deviceBrand => _brand.toString().toLowerCase();
  static String get _model => _dMap?['model'] ?? _dMap?['modelName'] ?? 'null';
  static String get deviceModel => _model.toString().toLowerCase();

  // 应用信息
  static PackageInfo? _pMap;
  static PackageInfo? get packageInfo => _pMap;
  static String get packageName => _pMap?.appName ?? '';
  static String get packageId => _pMap?.packageName ?? '';
  static String get packageVersion => _pMap?.version ?? '';
  static String get packageVersionCode => _pMap?.buildNumber ?? '';
  static String get packageSignature => _pMap?.buildSignature ?? '';
  static String get packageUserAgent =>
      '$packageId($packageVersion;$packageVersionCode)';

  // 屏幕信息
  static final Map<String, dynamic> _sMap = {};
  static Map<String, dynamic> get screenInfo => _sMap;
  static double get displayWidth => _sMap['displayWidth'] ?? 0;
  static double get displayHeight => _sMap['displayHeight'] ?? 0;
  static double get windowWidth => _sMap['windowWidth'] ?? 0;
  static double get windowHeight => _sMap['windowHeight'] ?? 0;
  static double get devicePixelRatio => _sMap['devicePixelRatio'] ?? 0;
  static double get viewPaddingTop => _sMap['viewPaddingTop'] ?? 0;
  static double get viewPaddingBottom => _sMap['viewPaddingBottom'] ?? 0;
  static double get viewPaddingLeft => _sMap['viewPaddingLeft'] ?? 0;
  static double get viewPaddingRight => _sMap['viewPaddingRight'] ?? 0;

  /// 初始化
  static Future<SharedPreferences> init() async {
    debugPrint('m_utils.dart~init: ');
    WidgetsFlutterBinding.ensureInitialized();
    pref = await SharedPreferences.getInstance();
    if (!isMobile) return pref;
    docsDir = (await getApplicationSupportDirectory()).path;
    tempDir = (await getTemporaryDirectory()).path;
    debugPrint('m_utils.dart~docsDir: $docsDir');
    debugPrint('m_utils.dart~tempDir: $tempDir');
    _dMap ??= (await DeviceInfoPlugin().deviceInfo).data;
    debugPrint('m_utils.dart~deviceInfo: $_dMap');
    _pMap ??= await PackageInfo.fromPlatform();
    debugPrint('m_utils.dart~packageInfo: $_pMap');
    final v = PlatformDispatcher.instance.views.last;
    _sMap.addAll({'displayWidth': v.display.size.width});
    _sMap.addAll({'displayHeight': v.display.size.height});
    _sMap.addAll({'windowWidth': v.physicalSize.width});
    _sMap.addAll({'windowHeight': v.physicalSize.height});
    _sMap.addAll({'devicePixelRatio': v.devicePixelRatio});
    _sMap.addAll({'viewPaddingTop': v.viewPadding.top});
    _sMap.addAll({'viewPaddingBottom': v.viewPadding.bottom});
    _sMap.addAll({'viewPaddingLeft': v.viewPadding.left});
    _sMap.addAll({'viewPaddingRight': v.viewPadding.right});
    debugPrint('m_utils.dart~screenInfo: $_sMap');
    return pref;
  }
}
