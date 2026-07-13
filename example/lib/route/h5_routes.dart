import 'dart:io';

import '../app_import.dart';
import '../dto/app_version_resp.dart';

class H5Routes {
  H5Routes._();

  /// 是否启用H5路由
  static bool enabled = true;

  /// 是否启用离线路由
  static bool enabledOffline = true;

  /// 一些在线h5页面路径
  static const String homePath = '/';
  static const String infoPath = '/info';

  ///  url 中添加 token
  static String urlInsetToken(String url, {String tokenKey = 'appToken'}) {
    Uri uri = Uri.parse(url);
    uri = uri.replace(
      queryParameters: {...uri.queryParameters, tokenKey: UserStore.to.token},
    );
    return uri.toString();
  }

  /// 从 path 中生成 url
  static String urlFromPath(
    String path, {
    bool useToken = true,
    String tokenKey = 'appToken',
  }) {
    Uri uri = Uri.parse(ServerManager.optVal('h5Host') + path);
    String url = useToken ? urlInsetToken(uri.toString()) : uri.toString();
    debugPrint('h5_routes.dart~urlFromPath: $url');
    return url;
  }

  static int versionInt(String v) {
    return v.split('.').map((r) => r.padLeft(5, '0')).join().toInt();
  }

  static String offlineUrl = '';
  static Future<void> initOffline() async {
    debugPrint('h5_routes.dart~initOffline: ${DateTime.now().str}');
    H5Offline().startServer().then((url) {
      debugPrint('h5_routes.dart~initOffline.startServer: $url');
      if (url.isEmpty) {
        _checkVersion(() async {
          offlineUrl = await H5Offline().startServer();
          debugPrint('h5_routes.dart~initOffline: $offlineUrl');
        });
        return;
      }
      offlineUrl = url;
      debugPrint('h5_routes.dart~initOffline: $offlineUrl');
    });
  }

  static Future<void> _checkVersion([void Function()? callback]) async {
    debugPrint('h5_routes.dart~_checkVersion: ${DateTime.now().str}');
    apiRequest(
      () => CommonApi.findH5Version(),
      AppVersionResp(
        upgradeFlag: 1,
        version: '1.0.0',
        storagePath:
            // 'https://github.com/jawa0919/m_utils/raw/refs/heads/main/doc/dist.zip',
            'https://ghfast.top/https://raw.githubusercontent.com/jawa0919/m_utils/main/doc/dist.zip',
        // 'https://fastly.jsdelivr.net/gh/jawa0919/m_utils@main/doc/dist.zip',
      ).toJson(),
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
