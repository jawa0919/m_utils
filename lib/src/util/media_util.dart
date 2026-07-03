import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

class MediaUtil {
  MediaUtil._();

  /// 保存网络图片到相册
  static Future<SaveResult> saveImageBytesToPhotosAlbum(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final hasPermission = await _checkGalleryPermissions(false);
    if (!hasPermission) return SaveResult(false, 'no permission');
    return await SaverGallery.saveImage(
      imageBytes,
      fileName: fileName,
      skipIfExists: false,
    );
  }

  /// 保存网络图片到相册
  static Future<SaveResult> saveNetImageToPhotosAlbum(
    String url,
    String fileName, {
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    final hasPermission = await _checkGalleryPermissions(false);
    if (!hasPermission) return SaveResult(false, 'no permission');
    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onReceiveProgress,
    );
    return await SaverGallery.saveImage(
      Uint8List.fromList(response.data),
      fileName: fileName,
      skipIfExists: false,
    );
  }

  /// 检查相册保存权限
  static Future<bool> _checkGalleryPermissions(bool skipIfExists) async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (skipIfExists) {
        return sdkInt >= 33
            ? await Permission.photos.request().isGranted
            : await Permission.storage.request().isGranted;
      } else {
        return sdkInt >= 29
            ? true
            : await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return skipIfExists
          ? await Permission.photos.request().isGranted
          : await Permission.photosAddOnly.request().isGranted;
    }
    return false;
  }

  /// 保存网络媒体到相册
  static Future<SaveResult> saveNetMediaToPhotosAlbum(
    String url,
    String fileName, {
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    final hasPermission = await _checkGalleryPermissions(false);
    if (!hasPermission) return SaveResult(false, 'no permission');
    var tempDir = await Directory.systemTemp.createTemp('net_media_temp');
    var tempFile = File('${tempDir.path}/$fileName');
    await Dio().download(
      url,
      tempFile.path,
      onReceiveProgress: onReceiveProgress,
    );
    return await SaverGallery.saveFile(
      filePath: tempFile.path,
      fileName: fileName,
      skipIfExists: false,
    );
  }
}
