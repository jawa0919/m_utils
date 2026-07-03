import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'app.dart';
import 'app_import.dart';

void main() async {
  debugPrint('main.dart~running: isProduct-${MUtils.isProduct}');
  // ignore: unused_local_variable
  final wfb = WidgetsFlutterBinding.ensureInitialized();
  // wfb.deferFirstFrame();
  // wfb.resetFirstFrameSent();
  await MUtils.init();
  await _initSystem();
  await _printDebugMessage();
  runApp(const App());
}

Future<void> _initSystem() async {
  ServerManager.init(
    AppConst.serverList,
    MUtils.isProduct ? 'prod' : 'dev',
    () {
      AppApi().updateBaseUrl(ServerManager.apiHost);
    },
  );
  ThemeStore.init(AppTheme.colorScheme);
  LanguageStore.init();
  AppRoutes.setPageLanguage();
  H5Routes.initOffline(ServerManager.env);
  if (MUtils.isMobile) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    List<DeviceOrientation> devOri = [DeviceOrientation.portraitUp];
    await SystemChrome.setPreferredOrientations(devOri);
  }
}

Future<void> _printDebugMessage() async {
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  if (!MUtils.isProduct) {
    debugPrint('..._printDebugMessage...');
    debugPrint('tempDir: ${MUtils.tempDir}');
    debugPrint('docsDir: ${MUtils.docsDir}');

    debugPrint('deviceVersion: ${MUtils.deviceVersion}');
    debugPrint('brand: ${MUtils.deviceBrand}');
    debugPrint('model: ${MUtils.deviceModel}');

    debugPrint('appName: ${MUtils.pkgName}');
    debugPrint('packageName: ${MUtils.pkgId}');
    debugPrint('buildVersion: ${MUtils.pkgVersion}');
    debugPrint('buildVersionCode: ${MUtils.pkgVersionCode}');
  }
}
