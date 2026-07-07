import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

import '../../app_import.dart';
import 'login_logic.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SignalsMixin, WidgetsBindingObserver, LoginLogic {
  @override
  Widget build(BuildContext context) {
    final bg = ThemeStore.to.isDark.value
        ? ThemeStore.color.secondaryContainer
        : ThemeStore.color.primary;
    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.language),
            onPressed: chooseSettingLanguage,
          ),
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemBar.style(bg),
        ),
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  height: 150,
                  width: 150,
                  margin: EdgeInsets.fromLTRB(0, 80, 0, 20),
                  color: Colors.red,
                  child: FlutterLogo(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                decoration: BoxDecoration(
                  color: ThemeStore.color.surfaceContainer,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loginType.watch(context) == 0)
                      ..._buildUsernameView(context)
                    else if (loginType.watch(context) == 1)
                      ..._buildPhoneView(context)
                    else
                      ...[],
                    if (loginType.watch(context) == 0)
                      ..._buildPasswordView(context)
                    else if (loginType.watch(context) == 1)
                      ..._buildCodeView(context)
                    else
                      ...[],
                    _buildConfirmView(context),
                    _buildAgreePolicyView(context),
                    _buildChangeTypeView(context),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Spacer(),
                  Center(
                    child: Container(
                      height: 160.w,
                      width: 800.w,
                      color: Colors.blue,
                      child: FlutterLogo(),
                    ).onHackerTap(navDebugPage),
                  ),
                  SafeArea(top: false, child: Container()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUsernameView(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Text(
          'LoginPage.账户'.tr,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 22 / 14,
            color: ThemeStore.color.onSurface,
          ),
        ),
      ),
      Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: TextField(
              controller: usernameCt,
              focusNode: usernameFN,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              showCursor: true,
              cursorWidth: 2,
              cursorHeight: 24,
              maxLines: 1,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              textInputAction: TextInputAction.next,
              // onSubmitted: trySendCode,
              onChanged: inputChanged,
              style: TextStyle(fontSize: 16, height: 24 / 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: ThemeStore.color.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ThemeStore.color.primary),
                ),
                counterText: '',
                errorText: usernameError.value.emptyToNull,
                hintText: 'LoginPage.请输入账户'.tr,
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: ThemeStore.color.outline,
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                suffixIcon: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 12, 0),
                  child: Icon(
                    Icons.clear,
                    size: 24,
                    color: ThemeStore.color.outline,
                  ),
                ).onTap(clearPhoneInput),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildPhoneView(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Text(
          'LoginPage.手机号码'.tr,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 22 / 14,
            color: ThemeStore.color.onSurface,
          ),
        ),
      ),
      Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: TextField(
              controller: phoneCt,
              focusNode: phoneFN,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              showCursor: true,
              cursorWidth: 2,
              cursorHeight: 24,
              maxLines: 1,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              textInputAction: TextInputAction.send,
              onSubmitted: trySendCode,
              onChanged: inputChanged,
              style: TextStyle(fontSize: 16, height: 24 / 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: ThemeStore.color.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ThemeStore.color.primary),
                ),
                counterText: '',
                errorText: phoneError.value.emptyToNull,
                hintText: 'LoginPage.请输入手机号'.tr,
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: ThemeStore.color.outline,
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                suffixIcon: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 12, 0),
                  child: Icon(
                    Icons.clear,
                    size: 24,
                    color: ThemeStore.color.outline,
                  ),
                ).onTap(clearPhoneInput),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildPasswordView(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.fromLTRB(32, 8, 32, 0),
        child: Text(
          'LoginPage.密码'.tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            height: 22 / 14,
            color: ThemeStore.color.onSurface,
          ),
        ),
      ),
      Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: TextField(
              controller: passwordCt,
              focusNode: passwordFN,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.url,
              showCursor: true,
              cursorWidth: 2,
              cursorHeight: 24,
              maxLines: 1,
              obscureText: passwordObscure.value,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                // LengthLimitingTextInputFormatter(6),
              ],
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => tryLogin,
              onChanged: inputChanged,
              style: TextStyle(fontSize: 16, height: 24 / 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: ThemeStore.color.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ThemeStore.color.primary),
                ),
                counterText: '',
                errorText: passwordError.value.emptyToNull,
                hintText: 'LoginPage.请输入密码'.tr,
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: ThemeStore.color.outline,
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                suffixIcon: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Icon(
                    passwordObscure.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 22,
                    color: ThemeStore.color.outline,
                  ),
                ).onTap(togglePasswordObscure),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildCodeView(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.fromLTRB(32, 8, 32, 0),
        child: Text(
          'LoginPage.验证码'.tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            height: 22 / 14,
            color: ThemeStore.color.onSurface,
          ),
        ),
      ),
      Builder(
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: TextField(
              controller: codeCt,
              focusNode: codeFN,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              showCursor: true,
              cursorWidth: 2,
              cursorHeight: 24,
              maxLines: 1,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => tryLogin,
              onChanged: inputChanged,
              style: TextStyle(fontSize: 16, height: 24 / 16),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: ThemeStore.color.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ThemeStore.color.primary),
                ),
                counterText: '',
                errorText: codeError.value.emptyToNull,
                hintText: 'LoginPage.请输入验证码'.tr,
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: ThemeStore.color.outline,
                ),
                suffixIconConstraints: BoxConstraints(
                  maxWidth: 128,
                  minHeight: 46,
                ),
                suffixIcon: Center(
                  child: Container(
                    width: 128,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: ThemeStore.color.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Builder(
                      builder: (BuildContext context) {
                        return Text(
                          timerCount.value > 0
                              ? 'LoginPage.59s'.trArgs([
                                  (timerMax - timerCount.value).toString(),
                                ])
                              : 'LoginPage.获取验证码'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 24 / 16,
                            color: ThemeStore.color.primary,
                          ),
                        ).onTap(tryRetryCode);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildConfirmView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(32, 24, 32, 8),
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        color: ThemeStore.color.primary,
      ),
      child: Text(
        'LoginPage.登录'.tr,
        style: TextStyle(
          fontSize: 20,
          height: 30 / 20,
          color: ThemeStore.color.onPrimary,
        ),
      ),
    ).onTap(tryLogin);
  }

  Widget _buildAgreePolicyView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Row(
        children: [
          Icon(
            isAgreed.value
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_rounded,
            size: 22,
            color: ThemeStore.color.onSurface,
          ).onTap(toggleAgreed),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'LoginPage.同意'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      height: 22 / 14,
                      color: ThemeStore.color.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: 'LoginPage.《隐私政策》'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      height: 22 / 14,
                      color: ThemeStore.color.primary,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = openPrivacy,
                  ),
                  TextSpan(
                    text: 'LoginPage.《服务协议》'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      height: 22 / 14,
                      color: ThemeStore.color.primary,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = openAgreement,
                  ),
                ],
              ),
              textAlign: TextAlign.left, // 文本整体居中
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeTypeView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(32, 16, 32, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loginType.value == 0
                ? 'LoginPage.手机验证登录'.tr
                : 'LoginPage.账号密码登录'.tr,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              color: ThemeStore.color.onSurface,
            ),
          ).onTap(() {
            changeLoginType(1 - loginType.value);
          }),
          Spacer(),
          Text(
            'LoginPage.注册'.tr,
            style: TextStyle(
              fontSize: 14,
              height: 22 / 14,
              color: ThemeStore.color.primary,
            ),
          ).onTap(navRegister),
          Icon(
            Icons.keyboard_double_arrow_right_rounded,
            size: 22,
            color: ThemeStore.color.primary,
          ).onTap(navRegister),
        ],
      ),
    );
  }
}

extension LoginPageLanguage on LoginPage {
  static final languageMap = {
    const Locale('zh', 'CN'): {
      'LoginPage.账户': '账户',
      'LoginPage.请输入账户': '请输入账户',
      'LoginPage.密码': '密码',
      'LoginPage.请输入密码': '请输入密码',
      'LoginPage.手机号码': '手机号码',
      'LoginPage.请输入手机号': '请输入手机号',
      'LoginPage.验证码': '验证码',
      'LoginPage.请输入验证码': '请输入验证码',
      'LoginPage.获取验证码': '获取验证码',
      'LoginPage.59s': '%ss',
      'LoginPage.登录': '登录',
      'LoginPage.同意': '同意',
      'LoginPage.《隐私政策》': '《隐私政策》',
      'LoginPage.《服务协议》': '《服务协议》',
      'LoginPage.手机验证登录': '手机验证登录',
      'LoginPage.账号密码登录': '账号密码登录',
      'LoginPage.注册': '注册',
    },
    const Locale('en', 'US'): {
      'LoginPage.账户': 'Account',
      'LoginPage.请输入账户': 'Please enter account',
      'LoginPage.密码': 'Password',
      'LoginPage.请输入密码': 'Please enter password',
      'LoginPage.手机号码': 'Phone Number',
      'LoginPage.请输入手机号': 'Please enter phone number',
      'LoginPage.验证码': 'Verification Code',
      'LoginPage.请输入验证码': 'Please enter verification code',
      'LoginPage.获取验证码': 'Get Code',
      'LoginPage.59s': '%ss',
      'LoginPage.登录': 'Log In',
      'LoginPage.同意': 'Agree',
      'LoginPage.《隐私政策》': '《Privacy Policy》',
      'LoginPage.《服务协议》': '《Terms of Service》',
      'LoginPage.手机验证登录': 'Phone Login',
      'LoginPage.账号密码登录': 'Account Login',
      'LoginPage.注册': 'Sign Up',
    },
  };
}
