import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_log_plus/dio_log_plus.dart';
import 'package:path/path.dart';

import '../store/language_store.dart' show LanguageString;

class HttpUtil {
  HttpUtil._();

  /// 网络状态
  static bool isNoneNetwork = false;
  static bool isMobile = false;
  static bool isWifi = false;
  static Connectivity connectivity = Connectivity()
    ..checkConnectivity().then((value) {
      isNoneNetwork = value.contains(ConnectivityResult.none);
      isMobile = value.contains(ConnectivityResult.mobile);
      isWifi = value.contains(ConnectivityResult.wifi);
      connectivity.onConnectivityChanged.listen((event) {
        isNoneNetwork = event.contains(ConnectivityResult.none);
        isMobile = event.contains(ConnectivityResult.mobile);
        isWifi = event.contains(ConnectivityResult.wifi);
      });
    });

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
  static const int connectionTimeoutCode = 0x0100;
  static const int sendTimeoutCode = 0x0101;
  static const int receiveTimeoutCode = 0x0102;
  static const int badCertificateCode = 0x0103;
  static const int badResponseCode = 0x0104;
  static const int cancelCode = 0x0105;
  static const int connectionErrorCode = 0x0106;
  static const int unknownCode = 0x0107;
  static const int transformTimeoutCode = 0x0108;

  static const int noneNetworkCode = 0x0200;
  final int code;
  final String message;
  SimpleException({required this.code, required this.message});

  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  String toString() {
    return 'SimpleException{code: $code, message: $message}';
  }
}

extension ExDioException on DioException {
  SimpleException get simpleException {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return SimpleException(
          code: SimpleException.connectionTimeoutCode,
          message: 'HttpUtil.连接超时'.tr,
        );
      case DioExceptionType.sendTimeout:
        return SimpleException(
          code: SimpleException.sendTimeoutCode,
          message: 'HttpUtil.请求超时'.tr,
        );
      case DioExceptionType.receiveTimeout:
        return SimpleException(
          code: SimpleException.receiveTimeoutCode,
          message: 'HttpUtil.响应超时'.tr,
        );
      case DioExceptionType.badCertificate:
        return SimpleException(
          code: SimpleException.badCertificateCode,
          message: 'HttpUtil.证书错误',
        );
      case DioExceptionType.badResponse:
        int statusCode = response?.statusCode ?? -1;
        switch (statusCode) {
          case 400:
            return SimpleException(code: 400, message: 'HttpUtil.请求参数错误'.tr);
          case 401:
            return SimpleException(code: 401, message: 'HttpUtil.未授权'.tr);
          case 403:
            return SimpleException(code: 403, message: 'HttpUtil.拒绝访问'.tr);
          case 404:
            return SimpleException(code: 404, message: 'HttpUtil.资源不存在'.tr);
          case 405:
            return SimpleException(code: 405, message: 'HttpUtil.方法不存在'.tr);
          case 500:
            return SimpleException(code: 500, message: 'HttpUtil.服务器错误'.tr);
          case 503:
            return SimpleException(code: 503, message: 'HttpUtil.服务不可用'.tr);
          default:
            return SimpleException(
              code: SimpleException.badResponseCode,
              message: '${'HttpUtil.服务错误'.tr} $statusCode',
            );
        }
      case DioExceptionType.cancel:
        return SimpleException(
          code: SimpleException.cancelCode,
          message: 'HttpUtil.请求取消'.tr,
        );
      case DioExceptionType.connectionError:
        if (HttpUtil.isNoneNetwork) {
          return SimpleException(
            code: SimpleException.noneNetworkCode,
            message: 'HttpUtil.无网络连接'.tr,
          );
        }
        return SimpleException(
          code: SimpleException.connectionErrorCode,
          message: 'HttpUtil.无法连接到服务器'.tr,
        );
      default:
        return SimpleException(
          code: SimpleException.unknownCode,
          message: 'HttpUtil.未知错误'.tr,
        );
    }
  }
}

extension HttpUtilLanguage on HttpUtil {
  static final map = {
    const Locale('zh', 'CN'): {
      'HttpUtil.连接超时': '连接超时',
      'HttpUtil.请求超时': '请求超时',
      'HttpUtil.响应超时': '响应超时',
      'HttpUtil.证书错误': '证书错误',
      'HttpUtil.请求参数错误': '请求参数错误',
      'HttpUtil.未授权': '未授权',
      'HttpUtil.拒绝访问': '拒绝访问',
      'HttpUtil.资源不存在': '资源不存在',
      'HttpUtil.方法不存在': '方法不存在',
      'HttpUtil.服务器错误': '服务器错误',
      'HttpUtil.服务不可用': '服务不可用',
      'HttpUtil.服务错误': '服务错误',
      'HttpUtil.请求取消': '请求取消',
      'HttpUtil.无网络连接': '无网络连接',
      'HttpUtil.无法连接到服务器': '无法连接到服务器',
      'HttpUtil.未知错误': '未知错误',
    },
    const Locale('en', 'US'): {
      'HttpUtil.连接超时': 'Connection Timeout',
      'HttpUtil.请求超时': 'Request Timeout',
      'HttpUtil.响应超时': 'Response Timeout',
      'HttpUtil.证书错误': 'Certificate Error',
      'HttpUtil.请求参数错误': 'Request Parameter Error',
      'HttpUtil.未授权': 'Unauthorized',
      'HttpUtil.拒绝访问': 'Forbidden',
      'HttpUtil.资源不存在': 'Not Found',
      'HttpUtil.方法不存在': 'Method Not Allowed',
      'HttpUtil.服务器错误': 'Internal Error',
      'HttpUtil.服务不可用': 'Service Unavailable',
      'HttpUtil.服务错误': 'Service Error',
      'HttpUtil.请求取消': 'Request Canceled',
      'HttpUtil.无网络连接': 'No Network Connection',
      'HttpUtil.无法连接到服务器': 'Failed to Connect to Server',
      'HttpUtil.未知错误': 'Unknown Error',
    },
  };
}
