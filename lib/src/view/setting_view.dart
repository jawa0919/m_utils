import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';

import '../debug/debug_page.dart';
import '../ext/ex_widget.dart';
import '../m_utils.dart';
import '../store/language_store.dart';
import '../store/theme_store.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  // 启动设置页面
  static void start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingView()),
    );
  }

  // 主题切换对话框
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

  // 语言切换对话框
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
                      // 主题切换实现
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
                      // 语言切换实现
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
                  onTap: () {
                    // 账号管理实现
                  },
                ),
                CupertinoListTile(
                  title: Text('SettingView.应用权限'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 应用权限实现
                  },
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
                    'v${MUtils.pkgVersion}(${MUtils.pkgVersionCode})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 检查更新实现
                  },
                ),
                CupertinoListTile(
                  title: Text('SettingView.服务协议'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 服务协议实现
                  },
                ),
                CupertinoListTile(
                  title: Text('SettingView.关于'.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 关于实现
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () {
                // 退出登录实现
              },
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
    const Locale('es', 'ES'): {
      'SettingView.设置': 'Ajustes',

      'SettingView.系统设置': 'Configuración del sistema',
      'SettingView.主题模式': 'Modo de tema',
      'SettingView.跟随系统': 'Seguir al sistema',
      'SettingView.浅色主题': 'Tema claro',
      'SettingView.深色主题': 'Tema oscuro',
      'SettingView.选择主题': 'Seleccionar tema',
      'SettingView.语言': 'Idioma',
      'SettingView.选择语言': 'Seleccionar idioma',

      'SettingView.账户设置': 'Configuración de la cuenta',
      'SettingView.账号管理': 'Gestión de cuentas',
      'SettingView.应用权限': 'Permisos de la aplicación',

      'SettingView.关于应用': 'Acerca de la aplicación',
      'SettingView.检查更新': 'Buscar actualizaciones',
      'SettingView.正在检查更新': 'Buscando actualizaciones...',
      'SettingView.已经是最新版本了': 'Ya está en la última versión',
      'SettingView.服务协议': 'Términos de servicio',
      'SettingView.关于': 'Acerca de',

      'SettingView.退出登录': 'Cerrar sesión',
    },
    const Locale('pt', 'PT'): {
      'SettingView.设置': 'Definições',

      'SettingView.系统设置': 'Definições do sistema',
      'SettingView.主题模式': 'Modo de tema',
      'SettingView.跟随系统': 'Seguir o sistema',
      'SettingView.浅色主题': 'Tema claro',
      'SettingView.深色主题': 'Tema escuro',
      'SettingView.选择主题': 'Selecionar tema',
      'SettingView.语言': 'Idioma',
      'SettingView.选择语言': 'Selecionar idioma',

      'SettingView.账户设置': 'Definições da conta',
      'SettingView.账号管理': 'Gestão de contas',
      'SettingView.应用权限': 'Permissões da aplicação',

      'SettingView.关于应用': 'Sobre a aplicação',
      'SettingView.检查更新': 'Verificar atualizações',
      'SettingView.正在检查更新': 'A verificar atualizações...',
      'SettingView.已经是最新版本了': 'Já está na versão mais recente',
      'SettingView.服务协议': 'Termos de serviço',
      'SettingView.关于': 'Sobre',

      'SettingView.退出登录': 'Terminar sessão',
    },
    const Locale('ja', 'JP'): {
      'SettingView.设置': '設定',

      'SettingView.系统设置': 'システム設定',
      'SettingView.主题模式': 'テーマモード',
      'SettingView.跟随系统': 'システムに従う',
      'SettingView.浅色主题': 'ライトテーマ',
      'SettingView.深色主题': 'ダークテーマ',
      'SettingView.选择主题': 'テーマを選択',
      'SettingView.语言': '言語',
      'SettingView.选择语言': '言語を選択',

      'SettingView.账户设置': 'アカウント設定',
      'SettingView.账号管理': 'アカウント管理',
      'SettingView.应用权限': 'アプリ権限',

      'SettingView.关于应用': 'アプリについて',
      'SettingView.检查更新': '更新を確認',
      'SettingView.正在检查更新': '更新を確認中',
      'SettingView.已经是最新版本了': '最新バージョンです',
      'SettingView.服务协议': 'サービス契約',
      'SettingView.关于': 'について',

      'SettingView.退出登录': 'ログアウト',
    },
    const Locale('ko', 'KR'): {
      'SettingView.设置': '설정',

      'SettingView.系统设置': '시스템 설정',
      'SettingView.主题模式': '테마 모드',
      'SettingView.跟随系统': '시스템 따라가기',
      'SettingView.浅色主题': '라이트 테마',
      'SettingView.深色主题': '다크 테마',
      'SettingView.选择主题': '테마 선택',
      'SettingView.语言': '언어',
      'SettingView.选择语言': '언어 선택',

      'SettingView.账户设置': '계정 설정',
      'SettingView.账号管理': '계정 관리',
      'SettingView.应用权限': '앱 권한',

      'SettingView.关于应用': '앱 정보',
      'SettingView.检查更新': '업데이트 확인',
      'SettingView.正在检查更新': '업데이트 확인 중',
      'SettingView.已经是最新版本了': '최신 버전입니다',
      'SettingView.服务协议': '서비스 약관',
      'SettingView.关于': '정보',

      'SettingView.退出登录': '로그아웃',
    },
  };
}
