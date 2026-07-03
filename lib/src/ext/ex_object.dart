import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class MapDynamic {
  MapDynamic._();

  static T? val<T>(dynamic map, String key1, [String? key2, String? key3]) {
    if (map is! Map<String, dynamic>) return null;
    if (map[key1] != null) return map[key1];
    if (key2 != null && map[key2] != null) return map[key2];
    if (key3 != null && map[key3] != null) return map[key3];
    return null;
  }

  static bool has(dynamic map, String key) {
    if (map is! Map<String, dynamic>) return false;
    return map.containsKey(key);
  }
}

class ListDynamic {
  ListDynamic._();

  static T? val<T>(dynamic list, int index) {
    if (list is! List<dynamic>) return null;
    if (list.isEmpty) return null;
    if (index < 0) return null;
    if (list.length <= index) return null;
    return list[index];
  }
}

extension TrueBool on bool? {
  bool get random => this == math.Random().nextBool();
  bool get isNull => this == null;
  bool get isTrue => this == true;
  bool get isFalse => this == false;
}

extension RoundDouble on double {
  static double get random => math.Random().nextDouble();
  double roundTo(num value) => (this * value).round() / value;
  double roundToPrecision(int precision) {
    final factor = math.pow(10, precision);
    return (this * factor).round() / factor;
  }
}

extension RoundInt on int {
  int get random => math.Random().nextInt(this);
}

extension EmptyToNullString on String {
  String? get emptyToNull => isEmpty ? null : this;
}

extension TrueString on String? {
  bool get isNull => this == null;
  bool get isTrue => this == 'true';
  bool get isFalse => this == 'false';
  bool get isEmpty => this?.isEmpty ?? this == null;
  bool get isNotEmpty => !isEmpty;
  bool toBool([bool defaultValue = false]) => switch (this) {
    'true' => true,
    'false' => false,
    _ => defaultValue,
  };
}

extension NumString on String? {
  double toDouble([double defaultValue = 0.0]) =>
      double.tryParse(this ?? '$defaultValue') ?? defaultValue;
  int toInt([int defaultValue = 0]) =>
      int.tryParse(this ?? '$defaultValue') ?? defaultValue;
}

extension HexColorString on String {
  Color? get hexColor {
    if (isEmpty) return null;
    if (!startsWith('#')) return null;
    if (length == 7) {
      int? value = int.tryParse('ff${substring(1).toLowerCase()}', radix: 16);
      return value == null ? null : Color(value);
    }
    if (length == 9) {
      int? value = int.tryParse(substring(1).toLowerCase(), radix: 16);
      return value == null ? null : Color(value);
    }
    return null;
  }
}

extension HexStringColor on Color {
  bool get isDark => computeLuminance() < 0.5;
  bool get isAlpha => a != 255;
  String get hexString => '#${toARGB32().toRadixString(16)}';
  String get hexStringNoAlpha =>
      '#${toARGB32().toRadixString(16).substring(2)}';
}

extension ReverseBrightness on Brightness {
  Brightness get reverseBrightness => Brightness.values[index ^ 1];
}

extension StringDateTime on DateTime {
  String get str => toIso8601String()
      .replaceAll('-', '')
      .replaceAll('T', '')
      .replaceAll(':', '')
      .replaceAll('.', '');
  List<String> get strList => [
    year.toString().padLeft(4, '0'),
    month.toString().padLeft(2, '0'),
    day.toString().padLeft(2, '0'),
    hour.toString().padLeft(2, '0'),
    minute.toString().padLeft(2, '0'),
    second.toString().padLeft(2, '0'),
    millisecond.toString().padLeft(3, '0'),
    microsecond.toString().padLeft(3, '0'),
  ];
  String get dateStr => toIso8601String().split('T').first;
  String get timeStr => toIso8601String().split('T').last.split('.').first;
}

extension NewFileDirectory on Directory {
  File newFile(String name) => File('$path/$name');
  Directory newDirectory(String name) => Directory('$path/$name');
}

extension MapSize on Size {
  Map<String, dynamic> get json => {
    'aspectRatio': aspectRatio,
    'width': width,
    'height': height,
    'shortestSide': shortestSide,
    'longestSide': longestSide,
  };
  Map<String, dynamic> toJson() => json;
}

extension MapEdgeInsets on EdgeInsets {
  Map<String, dynamic> get json => {
    'left': left,
    'top': top,
    'right': right,
    'bottom': bottom,
  };
  Map<String, dynamic> toJson() => json;
}
