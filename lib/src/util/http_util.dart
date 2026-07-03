import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_log_plus/dio_log_plus.dart';
import 'package:path/path.dart';

class HttpUtil {
  HttpUtil._();
  static Connectivity connectivity = Connectivity();

  /// 创建dio
  static Dio create([
    String baseUrl = '',

    /// 请求超时3s
    int timeout = 3,

    /// 忽略https证书
    bool sslIgnore = true,

    /// 调试日志开关
    bool logDebug = true,
  ]) {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: timeout),
      receiveTimeout: Duration(seconds: timeout),
      headers: {'operatingSystem': Platform.operatingSystem},
    );
    Dio dio = Dio(options);
    if (sslIgnore) {
      final ad = dio.httpClientAdapter;
      if (ad is IOHttpClientAdapter) {
        ad.validateCertificate = (certificate, host, port) {
          // 忽略https证书
          // 也可以在此处验证证书/地址/端口
          return true;
        };
      }
    }
    if (logDebug) {
      dio.interceptors.add(DioLogInterceptor());
    }
    return dio;
  }

  static Future<SimpleException> createSimpleException(
    DioException error,
  ) async {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return SimpleException(code: -1, message: '连接超时');
      case DioExceptionType.sendTimeout:
        return SimpleException(code: -1, message: '请求超时');
      case DioExceptionType.receiveTimeout:
        return SimpleException(code: -1, message: '响应超时');
      case DioExceptionType.badCertificate:
        return SimpleException(code: -1, message: '证书错误');
      case DioExceptionType.badResponse:
        int errCode = error.response?.statusCode ?? -1;
        switch (errCode) {
          case 400:
            return SimpleException(code: errCode, message: '请求语法错误');
          case 401:
            return SimpleException(code: errCode, message: '没有权限');
          case 403:
            return SimpleException(code: errCode, message: '服务器拒绝执行');
          case 404:
            return SimpleException(code: errCode, message: '无法连接服务器');
          case 405:
            return SimpleException(code: errCode, message: '请求方法被禁止');
          case 500:
            return SimpleException(code: errCode, message: '服务器内部错误');
          case 502:
            return SimpleException(code: errCode, message: '无效的请求');
          case 503:
            return SimpleException(code: errCode, message: '服务器挂了');
          case 505:
            return SimpleException(code: errCode, message: '不支持HTTP协议请求');
          default:
            return SimpleException(
              code: errCode,
              message: error.response?.statusMessage ?? '未知错误码$errCode',
            );
        }
      case DioExceptionType.cancel:
        return SimpleException(code: -1, message: '请求取消');
      case DioExceptionType.connectionError:
        final results = await Connectivity().checkConnectivity();
        if (results.contains(ConnectivityResult.none)) {
          String message = '无网络连接,请检查网络状态/网络设置';
          return SimpleException(code: -1, message: message);
        }
        return SimpleException(code: -1, message: '无法连接到服务器');
      default:
        final results = await Connectivity().checkConnectivity();
        if (results.contains(ConnectivityResult.none)) {
          String message = '无网络连接,请检查网络状态/网络设置';
          return SimpleException(code: -1, message: message);
        }
        return SimpleException(code: -1, message: '未知错误:${error.error}');
    }
  }

  /// 下载文件
  static Future<Response> downloadFile(
    String fullUrl,
    String savePath, {
    String method = 'GET',
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    ProgressCallback? onReceiveProgress,

    /// 请求超时3*60s
    int timeout = 3 * 60,

    /// 忽略https证书
    bool sslIgnore = true,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: timeout),
        receiveTimeout: Duration(seconds: timeout),
        sendTimeout: Duration(seconds: timeout),
      ),
    );

    if (sslIgnore) {
      final ad = dio.httpClientAdapter;
      if (ad is IOHttpClientAdapter) {
        ad.validateCertificate = (certificate, host, port) {
          // 忽略https证书
          // 也可以在此处验证证书/地址/端口
          return true;
        };
      }
    }

    final options = Options(method: method, headers: headers);
    Response response = await dio.download(
      fullUrl,
      savePath,
      data: data,
      onReceiveProgress: onReceiveProgress,
      options: options,
    );
    return response;
  }

  /// 上传文件
  static Future<Response> uploadFile(
    String fullUrl,
    List<String> localFilePaths, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,

    /// 请求超时3*60s
    int timeout = 3 * 60,

    /// 忽略https证书
    bool sslIgnore = true,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: timeout),
        receiveTimeout: Duration(seconds: timeout),
        sendTimeout: Duration(seconds: timeout),
      ),
    );

    if (sslIgnore) {
      final ad = dio.httpClientAdapter;
      if (ad is IOHttpClientAdapter) {
        ad.validateCertificate = (certificate, host, port) {
          // 忽略https证书
          // 也可以在此处验证证书/地址/端口
          return true;
        };
      }
    }

    final options = Options(headers: headers);

    final formData = FormData();
    for (var value in localFilePaths) {
      final multipartFile = MultipartFile.fromFileSync(
        value,
        filename: basename(value),
      );
      formData.files.add(MapEntry('files[]', multipartFile));
    }
    data = data ?? {};
    data.forEach((key, value) => formData.fields.add(MapEntry(key, '$value')));

    Response response = await dio.post(
      fullUrl,
      queryParameters: queryParameters,
      data: formData,
      onSendProgress: onSendProgress,
      options: options,
    );
    return response;
  }

  /// 整合请求
  static Future<Response<T>> request<T>(
    String fullUrl, {
    String method = 'GET',
    Map<String, dynamic>? headers,
    dynamic data,

    /// 请求超时3s
    int timeout = 3,

    /// 忽略https证书
    bool sslIgnore = true,

    /// 调试日志开关
    bool logDebug = true,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: timeout),
        receiveTimeout: Duration(seconds: timeout),
        sendTimeout: Duration(seconds: timeout),
      ),
    );
    if (sslIgnore) {
      final ad = dio.httpClientAdapter;
      if (ad is IOHttpClientAdapter) {
        ad.validateCertificate = (certificate, host, port) {
          // 忽略https证书
          // 也可以在此处验证证书/地址/端口
          return true;
        };
      }
    }
    if (logDebug) {
      dio.interceptors.add(DioLogInterceptor());
    }
    final options = Options(method: method, headers: headers);
    return await dio.request<T>(fullUrl, data: data, options: options);
  }
}

class SimpleException implements Exception {
  final int code;
  final String message;
  SimpleException({required this.code, required this.message});

  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  String toString() {
    return 'SimpleException{code: $code, message: $message}';
  }
}
