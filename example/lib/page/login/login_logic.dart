import 'dart:async';

import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';
import 'package:dio_log_plus/dio_log_plus.dart' show showDebugBtn;

import '../../app_import.dart';
import '../../dto/login_user_resp.dart';
import '../home/home_page.dart';

mixin LoginLogic<T extends StatefulWidget>
    on SignalsMixin<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    onPageCreated();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onPageMounted(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onPageDestroyed(context);
    super.dispose();
  }

  /// 0-账号密码登录
  /// 1-手机号验证码登录
  /// 2-扫码登录-todo
  /// 3-网页跳转登录-todo
  /// 98-忘记密码-todo
  /// 99-注册账号-todo
  late var loginType = createSignal(0);

  var usernameCt = TextEditingController(text: '');
  var usernameFN = FocusNode();
  late var usernameError = createSignal('');

  var passwordCt = TextEditingController(text: '');
  var passwordFN = FocusNode();
  late var passwordError = createSignal('');
  late var passwordObscure = createSignal(true);

  var phoneCt = TextEditingController(text: '');
  var phoneFN = FocusNode();
  late var phoneError = createSignal('');

  Timer? timer;
  int get timerMax => 60;
  late var timerCount = createSignal(0);

  var codeCt = TextEditingController(text: '');
  var codeFN = FocusNode();
  var codeError = signal('');

  late var isRememberMe = createSignal(true);
  late var isAgreed = createSignal(true);

  void onPageCreated() {
    usernameCt.text = UserStore.to.lastLoginUser.value;
    phoneCt.text = UserStore.to.lastLoginUser.value;
  }

  void onPageMounted(BuildContext context) {
    if (!MUtils.isProduct) {
      showDebugBtn(context);
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      usernameFN.requestFocus();
    });
  }

  void onPageDestroyed(BuildContext context) {}

  void chooseSettingLanguage() {
    SettingView.showLanguageDialog(context);
  }

  void trySendCode(String phone) {
    if (phone.length != 11) {
      phoneError.value = '请输入11位手机号';
      return;
    }
    if (!isAgreed.value) {
      ExDialog.showToast('请先阅读并同意协议');
      return;
    }
    if (timerCount.value > 0) return;
    debugPrint('login_logic.dart~trySendCode: $phone');
    ExDialog.showLoading('正在请求验证码');
    apiRequest(() => UserApi.sendCode(phone), {}, useMockData: true).then((r) {
      ExDialog.dismissLoading();
      if (!r.success) return;
      ExDialog.showToast('发送验证码成功');
      startTimer();
    });
  }

  void inputChanged(String v) async {
    if (phoneError.value.isNotEmpty) {
      phoneError.value = '';
    }
    if (codeError.value.isNotEmpty) {
      codeError.value = '';
    }
    if (usernameError.value.isNotEmpty) {
      usernameError.value = '';
    }
    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
    }
  }

  void startTimer() {
    if (timer != null && timerCount.value > 0) {
      timer?.cancel();
      timer = null;
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timerCount.value++;
      if (timerCount.value >= timerMax) {
        timer.cancel();
        timerCount.value = 0;
      }
    });
  }

  void cancelTimer() {
    timer?.cancel();
    timerCount.value = 0;
  }

  void clearPhoneInput() async {
    usernameCt.clear();
    usernameError.value = '';
    phoneCt.clear();
    phoneError.value = '';
  }

  void tryRetryCode() async {
    if (timerCount.value > 0) return;
    trySendCode(phoneCt.text);
  }

  void tryLogin([String? val]) async {
    if (loginType.value == 0) {
      tryLoginPassword(val);
    } else {
      tryLoginCode(val);
    }
  }

  void tryLoginPassword([String? val]) async {
    String username = usernameCt.text.trim();
    String password = passwordCt.text.trim();
    if (username.isEmpty) {
      usernameError.value = '请输入账户';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = '请输入密码';
      return;
    }
    if (!isAgreed.value) {
      ExDialog.showToast('请先阅读并同意协议');
      return;
    }
    debugPrint('login_logic.dart~tryLoginPassword: $username/$password');
    ExDialog.showLoading('正在登录');
    apiRequest(
      () => UserApi.login(username, password),
      LoginUserResp(token: 'login123456').toJson(),
      useMockData: true,
    ).then((r) async {
      await ExDialog.dismissLoading();
      if (!r.success) return;
      final resp = LoginUserResp.fromJson(r.data);
      debugPrint('login_logic.dart~117: ${resp.token}');
      await UserStore.to.saveToken(resp.token ?? '', false);
      await UserStore.to.saveProfile(resp);
      _loginSuccess();
    });
  }

  void tryLoginCode([String? val]) async {
    String phone = phoneCt.text.trim();
    String code = codeCt.text.trim();
    if (phone.length != 11) {
      phoneError.value = '请输入11位手机号';
      return;
    }
    if (code.length != 6) {
      codeError.value = '请输入6位验证码';
      return;
    }
    if (!isAgreed.value) {
      ExDialog.showToast('请先阅读并同意协议');
      return;
    }
    debugPrint('login_logic.dart~tryLoginCode: $phone/$code');
    ExDialog.showLoading('正在登录');
    apiRequest(
      () => UserApi.loginCode(phone, code),
      LoginUserResp(token: 'loginPhoneCode123456').toJson(),
      useMockData: true,
    ).then((r) async {
      await ExDialog.dismissLoading();
      if (!r.success) return;
      final resp = LoginUserResp.fromJson(r.data);
      debugPrint('login_logic.dart~token: ${resp.token}');
      await UserStore.to.saveToken(resp.token ?? '', false);
      await UserStore.to.saveProfile(resp);
      _loginSuccess();
    });
  }

  void _loginSuccess([String? val]) async {
    debugPrint('login_logic.dart~_loginSuccess: $val');
    AppRoutes.clearAllPush(HomePage.routeName);
  }

  void changeLoginType(int type) {
    loginType.value = type;
  }

  void togglePasswordObscure() {
    passwordObscure.value = !passwordObscure.value;
  }

  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
  }

  void toggleAgreed() {
    isAgreed.value = !isAgreed.value;
  }

  void navDebugPage() {
    SettingView.start(context);
  }

  void openPrivacy() {}

  void openAgreement() {}
}
