import 'dart:io';

import '../app_import.dart';
import '../dto/app_package_upgrade_resp.dart';

class H5Routes {
  H5Routes._();

  /// 格式化链接
  static String formateUrl(
    String path, [
    bool h5Host = true,
    bool token = true,
  ]) {
    Uri uri = Uri.parse(path);
    debugPrint('h5_urls.dart~uri: $uri');
    if (h5Host) {
      uri = Uri.parse(ServerManager.h5Host + path);
      debugPrint('h5_urls.dart~h5HostUri: $uri');
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
    debugPrint('h5_urls.dart~formateH5Url: $url');
    return url;
  }

  static int versionInt(String v) {
    return v.split('.').map((r) => r.padLeft(5, '0')).join().toInt();
  }

  static String offlineUrl = '';
  static Future<void> initOffline(String mode) async {
    debugPrint('h5_routes.dart~initOffline: $mode');
    final currentVersion = await H5Offline().getCurrentVersion();
    final nextVersion = await H5Offline().getNextVersion();
    SimpleResponse.withMock(
      AppPackageUpgradeResp(
        upgradeFlag: 1,
        version: '1.0.0',
        storagePath: 'https://example.com/1.0.0.zip',
      ).toJson(),
      () => CommonApi.loadH5VersionList(),
    ).then((res) async {
      debugPrint('h5_routes.dart~loadH5VersionList: ${DateTime.now().str}');
      if (!res.success) return;
      final r = AppPackageUpgradeResp.fromJson(res.data);
      if (r.upgradeFlag != 1) return;
      final remoteVersion = r.version ?? '0.0.1';
      if (remoteVersion == currentVersion) {
        debugPrint('h5_routes.dart~ ==: ${DateTime.now().str}');
        offlineUrl = await H5Offline().startServer();
      } else if (remoteVersion == nextVersion) {
        offlineUrl = await H5Offline().startServer();
      } else if (versionInt(remoteVersion) > versionInt(currentVersion)) {
        debugPrint('h5_routes.dart~ >: ${DateTime.now().str}');
        final versionDirectory = Directory.systemTemp;
        final fileName = r.storagePath?.split('/').last;
        final zipFile = File('${versionDirectory.path}/$fileName');
        if (zipFile.existsSync()) zipFile.deleteSync();
        HttpUtil.downloadFile(r.storagePath!, zipFile.path).then((dRes) async {
          debugPrint('h5_routes.dart~downloadFile: ${DateTime.now().str}');
          await H5Offline().releaseNextDist(zipFile.path, r.version!);
          if (!H5Offline().isRunning()) {
            offlineUrl = await H5Offline().startServer();
          }
        });
      } else {
        offlineUrl = await H5Offline().startServer();
        debugPrint('h5_routes.dart~<: ${DateTime.now().str}');
      }
    });

    /// 每10分钟轮询检查版本
    await Future.delayed(const Duration(minutes: 10), () => initOffline(mode));
  }
}
