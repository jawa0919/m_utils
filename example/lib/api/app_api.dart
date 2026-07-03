import 'dart:async';

import 'package:dio/dio.dart';

import '../app_import.dart';

part '_common_api.dart';
part '_user_api.dart';

class AppApi {
  static final AppApi _instance = AppApi._internal();
  factory AppApi() => _instance;

  late Dio dio;

  AppApi._internal() {
    dio = HttpUtil.create(ServerManager.apiHost);
    dio.interceptors.add(AppApiInterceptor());
  }

  void updateBaseUrl(String val) {
    debugPrint('app_api.dart~updateBaseUrl: $val');
    dio.options.baseUrl = val;
  }

  Future<T?> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
    Map<String, dynamic> cacheSetting = const {},
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
      'cacheSetting': cacheSetting,
    });
    var response = await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
    });
    var response = await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  Future<T?> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
    });
    var response = await dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  Future<T?> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
    });
    var response = await dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  Future<T?> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
    });
    var response = await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  Future<T?> head<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool autoToken = true,
    bool codeErrorToast = true,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra?.addAll({
      'autoToken': autoToken,
      'codeErrorToast': codeErrorToast,
    });
    var response = await dio.head<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }
}

class AppApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (UserStore.to.hasToken == true || options.extra['autoToken'] == true) {
      options.headers.update(
        'Authorization',
        (value) => UserStore.to.token,
        ifAbsent: () => UserStore.to.token,
      );
    }
    options.headers.update(
      'X-Lang',
      (value) => LanguageStore.to.locale.value.toLanguageTag(),
      ifAbsent: () => LanguageStore.to.locale.value.toLanguageTag(),
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    if (response.data is Map<String, dynamic>) {
      final reqExtra = response.requestOptions.extra;
      final resData = response.data as Map<String, dynamic>;
      if (resData['code'] != 200 && reqExtra['codeErrorToast'] == true) {
        ExDialog.showToast(resData['message'] ?? resData['msg'] ?? '错误未知');
      }
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    ExDialog.dismiss();
    debugPrint('app_api.dart~onError: $err');
    final se = await HttpUtil.createSimpleException(err);
    if (err.requestOptions.extra['ignoreException'] == true) {
      final r = Response(data: se.toJson(), requestOptions: err.requestOptions);
      return handler.resolve(r);
    }
    ExDialog.showToast(se.message);
    switch (se.code) {
      case 401:
        UserStore.to.clearToken();
        UserStore.to.offAndToLoginPage('登陆已超时,请重新登陆');
      default:
    }
    final r = Response(data: se.toJson(), requestOptions: err.requestOptions);
    return handler.resolve(r);
  }
}

class SimpleResponse<T> {
  final int code;
  final String message;
  final T? data;

  SimpleResponse({required this.code, required this.message, this.data});

  factory SimpleResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromMapT,
  }) {
    return SimpleResponse<T>(
      code: json['code'],
      message: json['message'] ?? json['msg'] ?? '',
      data: fromMapT?.call(json['data']) ?? json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data,
  };

  @override
  String toString() {
    return 'SimpleResponse{code: $code, message: $message, data: $data}';
  }

  bool get success => code == SUCCESS_CODE;
  // ignore: constant_identifier_names
  static const SUCCESS_CODE = 200;

  const SimpleResponse.success(
    this.data, {
    this.message = 'success',
    this.code = SUCCESS_CODE,
  });

  static const isUseMock = !bool.fromEnvironment('dart.vm.product') && true;
  static Future<SimpleResponse<T>> withMock<T>(
    T? data,
    Future<SimpleResponse<T>> Function() realRequest,
  ) async {
    if (!isUseMock) return await realRequest();
    debugPrint('withMockSuccess: --------------------------------------------');
    debugPrint('withMockSuccess: $data');
    debugPrint('withMockSuccess: --------------------------------------------');
    await Future.delayed(const Duration(seconds: 1));
    return SimpleResponse.success(data);
  }
}
