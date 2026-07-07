import 'dart:io';
import 'dart:convert';

import 'package:signals/signals.dart';

import '../app_import.dart';
import '../dto/login_user_resp.dart';
import '../page/login/login_page.dart';

/// 用户配置
class UserStore {
  static final UserStore to = _instance;
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;

  String token = '';
  bool get hasToken => token.isNotEmpty;

  final _profile = signal<LoginUserResp>(LoginUserResp());
  late final profile = computed(() => _profile.value);
  late final id = computed(() => _profile.value.id ?? '');
  late final email = computed(() => _profile.value.email ?? '');
  late final phone = computed(() => _profile.value.phone ?? '');
  late final surname = computed(() => _profile.value.surname ?? '');
  late final name = computed(() => _profile.value.name ?? '');
  late final nickName = computed(() => '${surname.value}${name.value}');
  late final headImage = computed(() => _profile.value.avatar ?? '');
  late final level = computed(() => _profile.value.level ?? 0);
  late final lastLoginUser = signal('');

  UserStore._internal() {
    debugPrint('user_store.dart~onInit: ');
    token = MUtils.pref.getString('token') ?? '';
    final profileJson = MUtils.pref.getString('profile') ?? '{}';
    _profile.value = LoginUserResp.fromJson(jsonDecode(profileJson));
    lastLoginUser.value = MUtils.pref.getString('lastLoginUser') ?? '';
    H5Logic().setupHandler('userLogout', (arguments) async {
      String tips = ListDynamic.val(arguments, 0) ?? '';
      offAndToLoginPage(tips);
    });
    SettingView.onAction(SettingAction.logout, onLogout);
  }

  Future<void> saveToken(String val, [bool updateProfile = true]) async {
    if (token != val) {
      await MUtils.pref.setString('token', val);
      token = val;
      H5Logic().postCustomEvent('appTokenUpdate', {'token': val});
    }
    if (updateProfile) {
      var r = await SimpleResponse.withMock(
        LoginUserResp().toJson(),
        () => UserApi.info(),
      );
      if (!r.success) return;
      final resp = LoginUserResp.fromJson(r.data);
      await saveProfile(resp);
    }
  }

  Future<void> clearToken() async {
    debugPrint('user_store.dart~clearToken: ');
    await MUtils.pref.remove('token');
    token = '';
  }

  Future<void> saveProfile(LoginUserResp val) async {
    await MUtils.pref.setString('profile', jsonEncode(val));
    _profile.value = val;
    await saveLastLoginUser(val.email ?? '');
  }

  Future<void> clearProfile() async {
    debugPrint('user_store.dart~clearProfile: ');
    await MUtils.pref.remove('profile');
    _profile.value = const LoginUserResp();
  }

  Future<void> saveLastLoginUser(String val) async {
    await MUtils.pref.setString('lastLoginUser', val);
    lastLoginUser.value = val;
  }

  void offAndToLoginPage(String tips) async {
    AppRoutes.clearAllPush(LoginPage.routeName, {'tips': tips});
  }

  Future<void> onLogout({
    bool removeProfile = true,
    bool toLoginPage = true,
    String tips = '',
  }) async {
    debugPrint(
      'user_store.dart~onLogout: '
      'removeProfile: $removeProfile toLoginPage: $toLoginPage tips: $tips',
    );
    await SimpleResponse.withMock({}, () => UserApi.logout());
    await clearToken();
    if (removeProfile) await clearProfile();
    if (toLoginPage) {
      offAndToLoginPage(tips);
      return;
    }
    exit(0);
  }
}
