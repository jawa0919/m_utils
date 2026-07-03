part of 'app_api.dart';

class CommonApi {
  CommonApi._();

  /// 查询应用版本号
  static Future<SimpleResponse<T>> findAppVersion<T>() async {
    var dataRes = await AppApi().get('/common/app/version', autoToken: false);
    return SimpleResponse<T>.fromJson(dataRes);
  }

  static Future<SimpleResponse> loadH5VersionList([int packageType = 2]) async {
    var dataRes = await AppApi().get(
      '/common/app/download/$packageType',
      autoToken: false,
    );
    return SimpleResponse.fromJson(dataRes);
  }
}
