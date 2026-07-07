part of 'app_api.dart';

class CommonApi {
  CommonApi._();

  /// 查询应用版本号
  static Future<SimpleResponse<T>> findAppVersion<T>() async {
    var dRes = await AppApi().get('/common/app/version', autoToken: false);
    return SimpleResponse<T>.fromJson(dRes);
  }

  /// 查询H5版本号
  static Future<SimpleResponse> findH5Version() async {
    var dRes = await AppApi().get('/common/app/version/h5', autoToken: false);
    return SimpleResponse.fromJson(dRes);
  }
}
