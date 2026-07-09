import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../store/language_store.dart' show LanguageString;

class ExDialog {
  ExDialog._();
  static final TransitionBuilder builder = FlutterSmartDialog.init();
  static final NavigatorObserver observer = FlutterSmartDialog.observer;

  static void dismiss<T>({T? result}) {
    SmartDialog.dismiss<T>(result: result);
  }

  static void showToast(String message) {
    SmartDialog.showToast(message);
  }

  static void showToastCenter(String message) {
    SmartDialog.showToast(message, alignment: Alignment.center);
  }

  static void showToastTop(String message) {
    SmartDialog.showToast(message, alignment: Alignment.topCenter);
  }

  static void showLoading([String? message]) {
    SmartDialog.showLoading(msg: message ?? 'ExDialog.正在加载'.tr);
  }

  static Future<void> dismissLoading() async {
    await SmartDialog.dismiss(status: SmartStatus.loading);
  }

  static void showRequestLoading([String? message]) {
    SmartDialog.showLoading(msg: message ?? 'ExDialog.正在请求'.tr);
  }

  static void requestSuccess([String? message]) {
    SmartDialog.showToast(message ?? 'ExDialog.请求失败'.tr);
  }

  static void requestFailed([String? message]) {
    SmartDialog.showToast(message ?? 'ExDialog.请求成功'.tr);
  }

  static Future<String?> showDialog(
    Widget child, {
    String? title,
    String confirmText = 'ok',
    Color? confirmColor,
    String? cancelText,
    Color? cancelColor,
    bool maskDismiss = false,
    bool backDismiss = true,
    Future<bool> Function(String buttonText)? beforeClose,
    Widget Function(BuildContext context)? buildTextLoading,
  }) async {
    return await SmartDialog.show<String>(
      clickMaskDismiss: maskDismiss,
      backType: backDismiss ? SmartBackType.normal : SmartBackType.block,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (title != null)
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16.0),
                constraints: BoxConstraints(minHeight: 120),
                alignment: Alignment.center,
                child: child,
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    if (cancelText != null)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final loading = StreamController<bool>();
                            return TextButton(
                              onPressed: () async {
                                if (beforeClose != null) {
                                  loading.add(true);
                                  final v = await beforeClose(cancelText);
                                  loading.add(false);
                                  if (!v) return;
                                }
                                SmartDialog.dismiss(result: cancelText);
                              },
                              child: StreamBuilder<bool>(
                                stream: loading.stream,
                                builder: (context, asyncSnapshot) {
                                  if (asyncSnapshot.data == true) {
                                    return buildTextLoading?.call(context) ??
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(),
                                        );
                                  }
                                  return Text(
                                    cancelText,
                                    style: TextStyle(
                                      color:
                                          cancelColor ??
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (cancelText != null)
                      VerticalDivider(
                        width: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final loading = StreamController<bool>();
                          return TextButton(
                            onPressed: () async {
                              if (beforeClose != null) {
                                loading.add(true);
                                final v = await beforeClose(confirmText);
                                loading.add(false);
                                if (!v) return;
                              }
                              SmartDialog.dismiss(result: confirmText);
                            },
                            child: StreamBuilder<bool>(
                              stream: loading.stream,
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.data == true) {
                                  return buildTextLoading?.call(context) ??
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(),
                                      );
                                }
                                return Text(
                                  confirmText,
                                  style: TextStyle(
                                    color:
                                        confirmColor ??
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String?> showBottomDialog(
    Widget child, {
    bool maskDismiss = true,
    bool backDismiss = true,
  }) async {
    return await SmartDialog.show<String>(
      clickMaskDismiss: maskDismiss,
      backType: backDismiss ? SmartBackType.normal : SmartBackType.block,
      alignment: Alignment.bottomCenter,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          padding: MediaQuery.of(context).padding.copyWith(top: 0),
          constraints: BoxConstraints(
            minHeight: 300,
            maxHeight: 500,
            minWidth: double.maxFinite,
          ),
          child: SingleChildScrollView(child: child),
        );
      },
    );
  }

  static Future<String?> showConfirm(
    String message, {
    String? title,
    String confirmText = 'ok',
    Color? confirmColor,
    String? cancelText,
    Color? cancelColor,
    bool maskDismiss = false,
    bool backDismiss = true,
    Future<bool> Function(String buttonText)? beforeClose,
    Widget Function(BuildContext context)? buildTextLoading,
  }) async {
    return showDialog(
      SelectableText(message),
      title: title,
      confirmText: confirmText,
      confirmColor: confirmColor,
      cancelText: cancelText,
      cancelColor: cancelColor,
      maskDismiss: maskDismiss,
      backDismiss: backDismiss,
      beforeClose: beforeClose,
      buildTextLoading: buildTextLoading,
    );
  }
}

extension ExDialogLanguage on ExDialog {
  static final map = {
    const Locale('zh', 'CN'): {
      'ExDialog.取消': '取消',
      'ExDialog.确认': '确认',
      'ExDialog.正在加载': '正在加载...',
      'ExDialog.完成': '完成',
      'ExDialog.正在请求': '正在请求...',
      'ExDialog.请求失败': '请求失败',
      'ExDialog.请求成功': '请求成功',
    },
    const Locale('en', 'US'): {
      'ExDialog.取消': 'Cancel',
      'ExDialog.确认': 'Confirm',
      'ExDialog.正在加载': 'Loading...',
      'ExDialog.完成': 'Done',
      'ExDialog.正在请求': 'Request...',
      'ExDialog.请求失败': 'Request Failed',
      'ExDialog.请求成功': 'Request Success',
    },
  };
}
