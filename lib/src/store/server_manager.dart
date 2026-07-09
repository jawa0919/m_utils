import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../m_utils.dart' show MUtils;

class ServerManager {
  ServerManager._();

  static Map<String, Map<String, String>> map = {};
  static String _env = '';
  static Map<String, String> _info = {};
  static String get env => _env;
  static Set<String> get envKes => _info.keys.toSet();
  static String? getVal(String key) => _info[key];
  static String optVal(String key) => _info[key] ?? '';

  static void init(
    Map<String, Map<String, String>> serverMap,
    String defaultEnv, [
    VoidCallback? onEnvChange,
  ]) {
    map = serverMap;
    _env = MUtils.pref.getString('serverEnv') ?? defaultEnv;
    if (_env == 'custom') {
      final serverCustomEnv = MUtils.pref.getString('serverCustom') ?? '{}';
      _info = jsonDecode(serverCustomEnv) as Map<String, String>;
      map['custom'] = _info;
    } else {
      _info = map[_env]!;
    }
    if (onEnvChange != null) addEnvChangeListener(onEnvChange);

    checkUpdateEpoch = MUtils.pref.getInt('checkUpdateEpoch') ?? 0;
  }

  /// 服务器环境改变监听
  static final List<VoidCallback> _changeListeners = [];
  static void addEnvChangeListener(VoidCallback listener) {
    if (!_changeListeners.contains(listener)) _changeListeners.add(listener);
  }

  static void removeEnvChangeListener(VoidCallback listener) {
    _changeListeners.remove(listener);
  }

  static void clearEnvListeners() => _changeListeners.clear();

  /// 保存服务器信息
  static void saveServerInfo(String env, Map<String, String> val) {
    MUtils.pref.setString('serverEnv', env);
    _env = env;
    _info = val;
    if (env == 'custom') {
      MUtils.pref.setString('serverCustom', jsonEncode(val));
      map['custom'] = val;
    }
    for (final listener in _changeListeners) {
      listener();
    }
  }

  /// 更新信息
  static int checkUpdateEpoch = 0;
  static bool get isFirstOpen => !MUtils.pref.containsKey('checkUpdateEpoch');
}
