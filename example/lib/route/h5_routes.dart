import 'dart:io';

import 'package:flutter/widgets.dart';

import '../app_import.dart';
import '../dto/app_version_resp.dart';

class H5Routes {
  H5Routes._();

  /// 是否启用H5路由
  static bool enabled = true;

  /// 是否启用离线路由
  static bool enabledOffline = true;

  /// 主页面
  static const String home = '/';

  /// 格式化链接
  static String formateUrl(
    String path, [
    bool h5Host = true,
    bool token = true,
  ]) {
    Uri uri = Uri.parse(path);
    debugPrint('h5_routes.dart~uri: $uri');
    if (h5Host) {
      uri = Uri.parse(ServerManager.optVal('h5Host') + path);
      debugPrint('h5_routes.dart~h5HostUri: $uri');
    }
    if (token) {
      uri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'appToken': UserStore.to.token,
        },
      );
    }
    String url = uri.toString();
    debugPrint('h5_routes.dart~formateH5Url: $url');
    return url;
  }

  static int versionInt(String v) {
    return v.split('.').map((r) => r.padLeft(5, '0')).join().toInt();
  }

  static String offlineUrl = '';
  static Future<void> initOffline() async {
    debugPrint('h5_routes.dart~initOffline: ${DateTime.now().str}');
    H5Offline().startServer().then((value) {
      if (value.isEmpty) {
        _checkVersion(() async {
          offlineUrl = await H5Offline().startServer();
          debugPrint('h5_routes.dart~initOffline: $offlineUrl');
        });
        return;
      }
      offlineUrl = value;
      debugPrint('h5_routes.dart~initOffline: $offlineUrl');
    });
  }

  static Future<void> _checkVersion([ValueGetter? callback]) async {
    debugPrint('h5_routes.dart~checkVersion: ${DateTime.now().str}');
    SimpleResponse.withMock(
      AppVersionResp(
        upgradeFlag: 1,
        version: '1.0.0',
        storagePath:
            // 'https://github.com/jawa0919/m_utils/raw/refs/heads/main/doc/dist.zip',
            'https://ghfast.top/https://raw.githubusercontent.com/jawa0919/m_utils/main/doc/dist.zip',
        // 'https://fastly.jsdelivr.net/gh/jawa0919/m_utils@main/doc/dist.zip',
      ).toJson(),
      () => CommonApi.findH5Version(),
    ).then((res) async {
      debugPrint('h5_routes.dart~findH5Version: ${DateTime.now().str}');
      if (!res.success) return;
      final r = AppVersionResp.fromJson(res.data);
      if (r.upgradeFlag != 1) return;
      final currentVersion = await H5Offline().getCurrentVersion();
      final nextVersion = await H5Offline().getNextVersion();
      final remoteVersion = r.version ?? '0.0.1';
      if (remoteVersion == currentVersion) {
        /// 当前版本
      } else if (remoteVersion == nextVersion) {
        /// 下一个版本, 无需下载
      } else if (versionInt(remoteVersion) > versionInt(currentVersion)) {
        debugPrint('h5_routes.dart~remoteVersion: $remoteVersion');
        final versionDirectory = Directory.systemTemp;
        final fileName = r.storagePath?.split('/').last;
        final zipFile = File('${versionDirectory.path}/$fileName');
        if (zipFile.existsSync()) zipFile.deleteSync();
        HttpUtil.downloadFile(r.storagePath!, zipFile.path).then((dRes) async {
          debugPrint('h5_routes.dart~downloadFile: ${DateTime.now().str}');
          await H5Offline().releaseNextDist(zipFile.path, r.version!);
          debugPrint('h5_routes.dart~releaseNextDist: ${DateTime.now().str}');
          callback?.call();
        });
      }
    });

    /// 每10分钟轮询检查版本
    await Future.delayed(const Duration(minutes: 10), () => _checkVersion());
  }
}
