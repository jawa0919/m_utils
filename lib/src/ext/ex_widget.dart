import 'package:flutter/material.dart';

extension OnTapContainer on Container {
  Widget onTap(GestureTapCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}

extension OnTapText on Text {
  Widget onTap(GestureTapCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}

extension OnTapIcon on Icon {
  Widget onTap(GestureTapCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}

/// 在2000毫秒间内完成【连续点击10以上后再长按一次】进入全局hacker点击模式
extension OnHackerTapContainer on Container {
  static bool _hackerEnable = false;
  Widget onHackerTap(GestureTapCallback? onTap) {
    const hackerTargetCount = 10;
    const hackerTimeout = 2000;
    var hackerLastTime = 0;
    var hackerCount = 0;
    return GestureDetector(
      onTap: () {
        if (_hackerEnable) {
          onTap?.call();
          return;
        }
        var current = DateTime.now().millisecondsSinceEpoch;
        var travel = current - hackerLastTime;
        if (travel > 0 && travel < hackerTimeout) {
          hackerCount++;
        } else {
          hackerCount = 1;
        }
        hackerLastTime = current;
      },
      onLongPress: () {
        if (hackerCount >= hackerTargetCount) {
          _hackerEnable = true;
          onTap?.call();
        }
      },
      child: AnimatedRotation(
        turns: hackerCount == hackerTargetCount ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: this,
      ),
    );
  }
}
