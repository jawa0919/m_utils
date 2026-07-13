part of 'app_api.dart';

class CommonApi {
  CommonApi._();

  /// 查询应用版本号
  static Future<SimpleResponse> findAppVersion() async {
    var dRes = await AppApi().get('/common/app/version', autoToken: false);
    return SimpleResponse.fromJson(dRes);
  }

  /// 查询H5版本号
  static Future<SimpleResponse> findH5Version() async {
    var dRes = await AppApi().customRequest(
      BaseOptions(baseUrl: ServerManager.optVal('subApi')),
      '/common/download/h5',
      autoToken: false,
      options: Options(method: 'GET', extra: {'ignoreException': true}),
    );
    return SimpleResponse.fromJson(dRes);
  }
}
