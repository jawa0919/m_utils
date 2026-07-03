import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:signals/signals.dart';

import '../ext/ex_theme.dart' show ResetThemeData;
import '../m_utils.dart' show MUtils;

class ThemeStore {
  ThemeStore._();
  static final ThemeStore _instance = ThemeStore._();
  static ThemeStore get instance => _instance;
  static ThemeStore get to => _instance;
  static ColorScheme get color => to._theme.value.colorScheme;

  static late ColorScheme _colorScheme;
  static void init(ColorScheme colorScheme) => _instance._internal(colorScheme);

  void _internal(ColorScheme colorScheme) {
    _colorScheme = colorScheme;
    debugPrint('theme_store.dart~_internal: ');
    _lightThemeIndex.value = MUtils.pref.getInt('_lightThemeIndex') ?? 0;
    _darkThemeIndex.value = MUtils.pref.getInt('_darkThemeIndex') ?? 0;
    themeModeIndex.value = MUtils.pref.getInt('_themeModeIndex') ?? 1;
  }

  static List<ThemeData> get lightList => [
    ThemeData(colorScheme: _colorScheme).reset,
  ];
  static List<ThemeData> get darkList => [ThemeData.dark().reset];

  final _lightThemeIndex = signal(0);
  final _darkThemeIndex = signal(0);
  final themeModeIndex = signal(1);
  late final lightTheme = computed(() => lightList[_lightThemeIndex.value]);
  late final darkTheme = computed(() => darkList[_darkThemeIndex.value]);
  late final themeMode = computed(() => ThemeMode.values[themeModeIndex.value]);
  late final isDark = computed(() {
    if (themeMode.value == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  });
  late final _theme = computed(() {
    return isDark.value ? darkTheme.value : lightTheme.value;
  });

  void toggleTheme() {
    if (themeModeIndex.value == 1) {
      themeModeIndex.value = 2;
    } else if (themeModeIndex.value == 2) {
      themeModeIndex.value = 1;
    } else {
      switch (SchedulerBinding.instance.platformDispatcher.platformBrightness) {
        case Brightness.light:
          themeModeIndex.value = 2;
          break;
        case Brightness.dark:
          themeModeIndex.value = 1;
          break;
      }
    }
    MUtils.pref.setInt('_themeModeIndex', themeModeIndex.value);
  }

  void saveThemeMode(ThemeMode themeMode) {
    themeModeIndex.value = themeMode.index;
    MUtils.pref.setInt('_themeModeIndex', themeModeIndex.value);
  }
}
