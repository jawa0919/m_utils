import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';

/// H5离线网页服务
/// - 固定目录：current（当前服务）、next（升级临时目录）
/// - 启动时若有 next，则自动替换 current
/// - 升级仅解压到 next，需手动调用 restartServer 或 startServer 应用
class H5Offline {
  static final Map<String, H5Offline> _cache = <String, H5Offline>{};
  factory H5Offline([String name = 'defaultName']) {
    return _cache.putIfAbsent(name, () => H5Offline._internal(name));
  }
  H5Offline._internal(this.name);

  final String name;
  String _homePath = '';
  String _currentVersion = '';
  HttpServer? _server;

  Future<void> _initPath() async {
    if (_homePath.isNotEmpty) return;
    final sDir = await getApplicationSupportDirectory();
    _homePath = p.join(sDir.path, 'h5_offline_$name');
    await Directory(_homePath).create(recursive: true);
  }

  Future<void> _extractZip(String zipPath, String destDir) async {
    final zipFile = File(zipPath);
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (var f in archive.files) {
      debugPrint('h5_offline.dart~archive.files: ${f.name}');
    }
    final indexFile = archive.files
        .where((f) => f.name == 'index.html')
        .toList();
    if (indexFile.isNotEmpty) {
      await extractArchiveToDisk(archive, destDir);
      return;
    }
    final dirEntries = archive.files.where((f) => f.isDirectory).where((f) {
      var fileName = f.name;
      if (fileName.startsWith('.')) {
        fileName = fileName.substring(1);
      }
      if (fileName.startsWith('/')) {
        fileName = fileName.substring(1);
      }
      if (fileName.endsWith('/')) {
        fileName = fileName.substring(0, fileName.length - 1);
      }
      return !fileName.contains('/');
    }).toList();
    if (dirEntries.length == 1) {
      final rootDirName = dirEntries.first.name;
      for (final file in archive.files) {
        String targetPath = file.name;
        if (targetPath.startsWith(rootDirName)) {
          targetPath = targetPath.substring(rootDirName.length);
          if (targetPath.startsWith('/')) targetPath = targetPath.substring(1);
        }
        if (targetPath.isEmpty) continue;
        final fullPath = '$destDir/$targetPath';
        if (file.isDirectory) {
          await Directory(fullPath).create(recursive: true);
        } else {
          final outFile = File(fullPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }
      return;
    } else {
      // throw Exception('zip包中没有index.html文件');
    }
  }

  Future<String> _readVersionFile(String dirPath) async {
    final file = File(p.join(dirPath, '.version'));
    if (file.existsSync()) return file.readAsStringSync();
    return '0.0.0';
  }

  Future<void> _writeVersionFile(String dirPath, String version) async {
    final file = File(p.join(dirPath, '.version'));
    await file.writeAsString(version);
  }

  bool isRunning() {
    return _server != null;
  }

  Future<String> getCurrentVersion() async {
    if (_currentVersion.isNotEmpty) return _currentVersion;
    await _initPath();
    final currentDir = Directory(p.join(_homePath, 'current'));
    if (await currentDir.exists()) {
      _currentVersion = await _readVersionFile(currentDir.path);
    }
    return _currentVersion;
  }

  Future<String> getNextVersion() async {
    await _initPath();
    final nextDir = Directory(p.join(_homePath, 'next'));
    if (await nextDir.exists()) {
      return await _readVersionFile(nextDir.path);
    }
    return '';
  }

  final _nextVersionReadyController = StreamController<String>.broadcast();
  void onNextVersionReadyListener(void Function(String version) callback) {
    _nextVersionReadyController.stream.listen(callback);
  }

  Future<String> startServer() async {
    debugPrint('h5_offline.dart~startServer: ');
    await _initPath();
    await _applyUpdateIfNeeded();
    final currentDir = Directory(p.join(_homePath, 'current'));
    if (!await currentDir.exists()) {
      // throw Exception('current目录不存在');
      return '';
    }
    _server = await _serveDist(currentDir.path);
    serverUrl.value = 'http://${_server?.address.host}:${_server?.port}';
    return serverUrl.value;
  }

  Future<void> _applyUpdateIfNeeded() async {
    await _initPath();
    final nextDir = Directory(p.join(_homePath, 'next'));
    if (!await nextDir.exists()) return;

    final currentDir = Directory(p.join(_homePath, 'current'));
    if (await currentDir.exists()) {
      await currentDir.delete(recursive: true);
    }
    await nextDir.rename(currentDir.path);
    _currentVersion = await _readVersionFile(currentDir.path);
  }

  Future<bool> releaseNextDist(String zipPath, String version) async {
    debugPrint('h5_offline.dart~releaseNextDist: $zipPath $version');
    await _initPath();
    final nextDir = Directory(p.join(_homePath, 'next'));
    if (await nextDir.exists()) {
      await nextDir.delete(recursive: true);
    }
    await nextDir.create(recursive: true);
    await _extractZip(zipPath, nextDir.path);

    // final indexFile = File(p.join(nextDir.path, 'index.html'));
    // if (!await indexFile.exists()) {
    //   await nextDir.delete(recursive: true);
    //   throw Exception('释放失败,zip包中没有index.html');
    // }

    await _writeVersionFile(nextDir.path, version);
    _nextVersionReadyController.add(version);
    return true;
  }

  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      serverUrl.value = '';
      _nextVersionReadyController.close();
    }
  }

  // Future<String> restartServer() async {
  //   await stopServer();
  //   return await startServer();
  // }

  final serverUrl = ValueNotifier<String>('');
  Future<bool> waitForServerUrl() async {
    final completer = Completer<bool>();
    void listener() {
      if (serverUrl.value.isNotEmpty && !completer.isCompleted) {
        completer.complete(true);
      }
    }

    serverUrl.addListener(listener);
    try {
      listener();
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => false,
      );
    } finally {
      serverUrl.removeListener(listener);
    }
  }

  Future<HttpServer> _serveDist(String distPath) async {
    final staticHandler = createStaticHandler(
      distPath,
      defaultDocument: 'index.html',
      listDirectories: true,
      useHeaderBytesForContentType: true,
    );
    Pipeline pipeline = const Pipeline();
    pipeline = pipeline.addMiddleware(
      logRequests(
        logger: (message, isError) {
          if (!isError) return;
          debugPrint('h5_offline.dart~logRequests: $isError $message');
        },
      ),
    );
    final handler = pipeline.addHandler((Request request) async {
      var response = await staticHandler(request);
      if (response.statusCode == 404) return Response.found('/');
      return response;
    });
    HttpServer ser = await serve(handler, InternetAddress.anyIPv4, 0);
    debugPrint('h5_offline.dart~_serveDist: ${ser.address.host}:${ser.port}');
    return ser;
  }
}
