part of 'app_api.dart';

/// 用户管理
class UserApi {
  UserApi._();

  /// 发送验证码
  static Future<SimpleResponse> sendCode(String phone) async {
    var dRes = await AppApi().post(
      '/api/customer/sendCode',
      data: {'phone': phone},
      autoToken: false,
    );
    return SimpleResponse.fromJson(dRes);
  }

  /// 用户注册
  static Future<SimpleResponse> register(
    String account,
    String password, {
    String surname = '',
    String name = '',
  }) async {
    var dRes = await AppApi().post(
      '/api/customer/register',
      data: {
        'account': account,
        'password': password,
        'surname': surname,
        'name': name,
      },
      autoToken: false,
    );
    return SimpleResponse.fromJson(dRes);
  }

  /// 退出登录
  static Future<SimpleResponse> logout() async {
    var dRes = await AppApi().post(
      '/api/customer/logout',
      options: Options(extra: {'ignoreException': true}),
    );
    return SimpleResponse.fromJson(dRes);
  }

  /// 用户登录
  static Future<SimpleResponse> login(String account, String password) async {
    var dRes = await AppApi().post(
      '/api/customer/login',
      data: {'account': account, 'password': password},
      autoToken: false,
    );
    return SimpleResponse.fromJson(dRes);
  }

  /// 用户登录-手机验证码
  static Future<SimpleResponse> loginCode(String code, String phone) async {
    var dRes = await AppApi().post(
      '/api/customer/login',
      data: {'code': code, 'phone': phone},
      autoToken: false,
    );
    return SimpleResponse.fromJson(dRes);
  }

  /// 重置密码
  static Future<SimpleResponse> resetPassword(
    String phone,
    String password,
    String code,
  ) async {
    var dataRes = await AppApi().post(
      '/api/customer/resetPassword',
      data: {'phone': phone, 'password': password, 'code': code},
      autoToken: false,
    );
    return SimpleResponse.fromJson(dataRes);
  }

  /// 修改账户信息
  static Future<SimpleResponse> updateAccount(String code, String phone) async {
    var dataRes = await AppApi().post(
      '/api/customer/updateAccount ',
      data: {'phone': phone, 'code': code},
    );
    return SimpleResponse.fromJson(dataRes);
  }

  /// 用户信息
  static Future<SimpleResponse> info() async {
    var dRes = await AppApi().get('/api/customer/info');
    return SimpleResponse.fromJson(dRes);
  }

  /// 修改用户信息
  static Future<SimpleResponse> updateInfo(Map<String, dynamic> data) async {
    var dataRes = await AppApi().post('/api/customer/updateInfo', data: data);
    return SimpleResponse.fromJson(dataRes);
  }
}
