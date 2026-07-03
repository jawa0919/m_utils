import 'package:flutter/foundation.dart';

import '../m_utils.dart' show MUtils;

class ServerManager {
  ServerManager._();

  static List<Map<String, dynamic>> list = [];
  static String _env = '';
  static Map<String, dynamic> _info = {};
  static String get env => _info['env']?.toString() ?? '';
  static String get apiHost => _info['apiHost']?.toString() ?? '';
  static String get h5Host => _info['h5Host']?.toString() ?? '';

  static void init(
    List<Map<String, dynamic>> serverList,
    String defaultEnv, [
    VoidCallback? onEnvChange,
  ]) {
    list = serverList;
    _env = MUtils.pref.getString('_serverEnv') ?? defaultEnv;
    if (_env == 'custom') {
      _info = {
        'env': 'custom',
        'apiHost': MUtils.pref.getString('custom_apiHost'),
        'h5Host': MUtils.pref.getString('custom_h5Host'),
      };
    } else {
      _info = list.firstWhere((element) => element['env'] == _env);
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
  static void saveServerInfo(Map<String, dynamic> val) {
    MUtils.pref.setString('_serverEnv', val['env']);
    _info = val;
    _env = val['env'];
    if (val['env'] == 'custom') {
      MUtils.pref.setString('custom_apiHost', val['apiHost']);
      MUtils.pref.setString('custom_h5Host', val['h5Host']);
    }
    for (final listener in _changeListeners) {
      listener();
    }
  }

  /// 更新信息
  static int checkUpdateEpoch = 0;
  static bool get isFirstOpen => !MUtils.pref.containsKey('checkUpdateEpoch');
}
