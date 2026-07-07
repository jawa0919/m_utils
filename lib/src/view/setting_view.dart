import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';

import '../debug/debug_page.dart';
import '../ext/ex_widget.dart';
import '../m_utils.dart';
import '../store/language_store.dart';
import '../store/theme_store.dart';

enum SettingAction {
  accountManager,
  appPermissions,
  checkUpdate,
  serviceAgreement,
  about,
  logout,
}

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  static void start(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingView()));
  }

  static void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('SettingView.选择主题'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              String modeText;

              switch (mode) {
                case ThemeMode.system:
                  modeText = 'SettingView.跟随系统'.tr;
                  break;
                case ThemeMode.light:
                  modeText = 'SettingView.浅色主题'.tr;
                  break;
                case ThemeMode.dark:
                  modeText = 'SettingView.深色主题'.tr;
                  break;
              }

              return RadioGroup<ThemeMode>(
                groupValue: ThemeStore.to.themeMode.value,
                onChanged: (value) {
                  if (value != null) {
                    ThemeStore.to.saveThemeMode(value);
                  }
                  Navigator.pop(context);
                },
                child: RadioListTile<ThemeMode>(
                  title: Text(modeText),
                  value: mode,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  static void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('SettingView.选择语言'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageStore.to.supportedLanguageNames
                .map((locale, languageText) {
                  return MapEntry(
                    locale,
                    RadioGroup<Locale>(
                      groupValue: LanguageStore.to.locale.value,
                      onChanged: (value) {
                        if (value != null) {
                          final index = LanguageStore.to.supportedLocales
                              .indexOf(value);
                          LanguageStore.to.saveLanguageIndex(index);
                        }
                        Navigator.pop(context);
                      },
                      child: RadioListTile<Locale>(
                        title: Text(languageText),
                        value: locale,
                      ),
                    ),
                  );
                })
                .values
                .toList(),
          ),
        );
      },
    );
  }

  static final _callbacks = <SettingAction, ValueGetter<void>?>{};

  static void onAction(SettingAction action, ValueGetter<void>? callback) {
    _callbacks[action] = callback;
  }

  static void _invoke(SettingAction action) {
    _callbacks[action]?.call();
  }

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('SettingView.设置'.tr).onTap(() {
          DebugPage.start(context);
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 主题设置
            _buildSettingSection(
              title: 'SettingView.系统设置'.tr,
              children: [
                Watch((c) {
                  final themeMode = ThemeStore.to.themeMode.value;
                  String themeText;

                  switch (themeMode) {
                    case ThemeMode.system:
                      themeText = 'SettingView.跟随系统'.tr;
                      break;
                    case ThemeMode.light:
                      themeText = 'SettingView.浅色主题'.tr;
                      break;
                    case ThemeMode.dark:
                      themeText = 'SettingView.深色主题'.tr;
                      break;
                  }

                  return CupertinoListTile(
                    title: Text('SettingView.主题模式'.tr),
                    additionalInfo: Text(
                      themeText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      SettingView.showThemeDialog(context);
                    },
                  );
                }),

                Watch((c) {
                  return CupertinoListTile(
                    title: Text('SettingView.语言'.tr),
                    additionalInfo: Text(
                      'language.name'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      SettingView.showLanguageDialog(context);
                    },
                  );
                }),
              ],
            ),

            // 账户设置
            _buildSettingSection(
              title: 'SettingView.账户设置'.tr,
              children: [
                CupertinoListTile(
                  title: Text('SettingView.账号管理'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      SettingView._invoke(SettingAction.accountManager),
                ),
                CupertinoListTile(
                  title: Text('SettingView.应用权限'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      SettingView._invoke(SettingAction.appPermissions),
                ),
              ],
            ),

            // 关于
            _buildSettingSection(
              title: 'SettingView.关于应用'.tr,
              children: [
                CupertinoListTile(
                  title: Text('SettingView.检查更新'.tr),
                  additionalInfo: Text(
                    'v${MUtils.packageVersion}(${MUtils.packageVersionCode})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => SettingView._invoke(SettingAction.checkUpdate),
                ),
                CupertinoListTile(
                  title: Text('SettingView.服务协议'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      SettingView._invoke(SettingAction.serviceAgreement),
                ),
                CupertinoListTile(
                  title: Text('SettingView.关于'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => SettingView._invoke(SettingAction.about),
                ),
              ],
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () => SettingView._invoke(SettingAction.logout),
              child: Text(
                'SettingView.退出登录'.tr,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建设置分组
  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

extension SettingViewLanguage on SettingView {
  static final map = {
    const Locale('zh', 'CN'): {
      'SettingView.设置': '设置',

      'SettingView.系统设置': '系统设置',
      'SettingView.主题模式': '主题模式',
      'SettingView.跟随系统': '跟随系统',
      'SettingView.浅色主题': '浅色主题',
      'SettingView.深色主题': '深色主题',
      'SettingView.选择主题': '选择主题',
      'SettingView.语言': '语言',
      'SettingView.选择语言': '选择语言',

      'SettingView.账户设置': '账户设置',
      'SettingView.账号管理': '账号管理',
      'SettingView.应用权限': '应用权限',

      'SettingView.关于应用': '关于应用',
      'SettingView.检查更新': '检查更新',
      'SettingView.正在检查更新': '正在检查更新',
      'SettingView.已经是最新版本了': '已经是最新版本了',
      'SettingView.服务协议': '服务协议',
      'SettingView.关于': '关于',

      'SettingView.退出登录': '退出登录',
    },
    const Locale('en', 'US'): {
      'SettingView.设置': 'Setting',

      'SettingView.系统设置': 'System Settings',
      'SettingView.主题模式': 'Theme Mode',
      'SettingView.跟随系统': 'Follow System',
      'SettingView.浅色主题': 'Light Theme',
      'SettingView.深色主题': 'Dark Theme',
      'SettingView.选择主题': 'Select Theme',
      'SettingView.语言': 'Language',
      'SettingView.选择语言': 'Select Language',

      'SettingView.账户设置': 'Account Settings',
      'SettingView.账号管理': 'Account Management',
      'SettingView.应用权限': 'Application Permissions',

      'SettingView.关于应用': 'About the App',
      'SettingView.检查更新': 'Check for Updates',
      'SettingView.正在检查更新': 'Checking for Updates',
      'SettingView.已经是最新版本了': 'Already up-to-date',
      'SettingView.服务协议': 'Service Agreement',
      'SettingView.关于': 'About',

      'SettingView.退出登录': 'Logout',
    },
  };
}
