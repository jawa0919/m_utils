import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:signals/signals.dart';

import '../m_utils.dart' show MUtils;
import '../ext/ex_object.dart';
import '../store/theme_store.dart';
import '../util/media_util.dart';

class H5Logic {
  static final H5Logic to = _instance;
  static final H5Logic _instance = H5Logic._internal();
  factory H5Logic() => _instance;
  H5Logic._internal() {
    debugPrint('h5_logic.dart~onInit: ');
  }

  void onPageCreated() {
    keyboardSubscription = KeyboardVisibilityController().onChange.listen(
      appKeyboardVisibilityChange,
    );
  }

  void onPageMounted(BuildContext context) {
    debugPrint('h5_logic.dart~onPageMounted: ');
    attachmentContext = context;
  }

  void onPageDestroyed(BuildContext context) {
    debugPrint('h5_logic.dart~onPageDestroyed: ');
    keyboardSubscription.cancel();
  }

  late StreamSubscription<bool> keyboardSubscription;
  var initialUrl = signal('', debugLabel: 'initialUrl');
  late final initialUrlRequest = computed(
    () => URLRequest(url: WebUri(initialUrl.value)),
  );
  BuildContext? attachmentContext;
  InAppWebViewController? webController;
  InAppWebViewSettings get initialSettings => InAppWebViewSettings(
    // cacheEnabled: false,
    // clearCache: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    upgradeKnownHostsToHTTPS: false,
    applicationNameForUserAgent: MUtils.packageUserAgent,
    // allowsBackForwardNavigationGestures: false,
    // useOnDownloadStart: true,
  );

  /// 当前url
  var currentUrl = signal('', debugLabel: 'currentUrl');

  /// 状态normal/loading/error
  var status = signal('normal');

  /// 状态栏是否隐藏
  var isFullScreen = signal(true);

  void addHandler() {
    debugPrint('h5_logic.dart~addHandler: ');
    handlers.forEach((key, value) {
      webController?.addJavaScriptHandler(handlerName: key, callback: value);
    });
    webController?.addJavaScriptHandler(
      handlerName: 'exitApp',
      callback: (List<dynamic> arguments) async {
        EasyDebounce.debounce(
          'exitApp-debounce',
          const Duration(milliseconds: 200),
          () => exit(0),
        );
        return true;
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'closeWindow',
      callback: (List<dynamic> arguments) {
        if (attachmentContext != null) {
          Navigator.pop(attachmentContext!);
        }
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'clearAllCache',
      callback: (List<dynamic> arguments) {
        InAppWebViewController.clearAllCache();
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'toggleFullScreen',
      callback: (List<dynamic> arguments) {
        isFullScreen.value = !isFullScreen.value;
        return appScreenInfoChange();
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'appScreenInfo',
      callback: (List<dynamic> arguments) {
        return appScreenInfoChange();
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'clearAllCache',
      callback: (List<dynamic> arguments) {
        InAppWebViewController.clearAllCache();
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'saveNetImageToPhotosAlbum',
      callback: (List<dynamic> arguments) async {
        debugPrint('h5_logic.dart~saveNetImageToPhotosAlbum: $arguments');
        String url = ListDynamic.val(arguments, 0) ?? '';
        String name = ListDynamic.val(arguments, 1) ?? '';
        return await MediaUtil.saveNetImageToPhotosAlbum(url, name);
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'saveNetMediaToPhotosAlbum',
      callback: (List<dynamic> arguments) async {
        debugPrint('h5_logic.dart~saveNetMediaToPhotosAlbum: $arguments');
        String url = ListDynamic.val(arguments, 0) ?? '';
        String name = ListDynamic.val(arguments, 1) ?? '';
        return await MediaUtil.saveNetMediaToPhotosAlbum(url, name);
      },
    );
    webController?.addJavaScriptHandler(
      handlerName: 'chooseAlbumImage',
      callback: (List<dynamic> arguments) async {
        var img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img == null) {
          return {'path': '', 'name': '', 'bytes': [], 'length': 0};
        }
        var fileType = img.name.split('.').last.toLowerCase();
        return {
          'path': img.path,
          'name': img.name,
          'bytes': await img.readAsBytes(),
          'length': await img.length(),
          'mimeType': img.mimeType ?? 'image/$fileType',
        };
      },
    );
  }

  Map<String, dynamic> appScreenInfoChange() {
    var screenInfo = {
      'isDark': ThemeStore.to.isDark.value,
      'displayHeight': MUtils.displayHeight,
      'windowWidth': MUtils.windowWidth,
      'windowHeight': MUtils.windowHeight,
      'devicePixelRatio': MUtils.devicePixelRatio,
      'viewPaddingRight': MUtils.viewPaddingRight,
      'viewPaddingTop': MUtils.viewPaddingTop,
      'viewPaddingLeft': MUtils.viewPaddingLeft,
      'viewPaddingBottom': MUtils.viewPaddingBottom,
      'isFullScreen': isFullScreen.value,
    };
    postCustomEvent('appScreenInfoChange', screenInfo);
    return screenInfo;
  }

  void appKeyboardVisibilityChange(bool visible) {
    postCustomEvent('appKeyboardVisibilityChange', {'visible': visible});
  }

  ///
  /// 发送自定义事件
  ///
  /// [param api] 事件名称
  /// [param detail] 事件详情
  ///
  /// web端处理发送自定义事件ts代码
  ///
  /// ```ts
  /// window.addEventListener(api, (event: Event) => {
  ///      var customEvent = event as CustomEvent<Record<string, any>>;
  ///      var detail: Record<string, any> = customEvent.detail;
  /// }, false);
  /// ```
  void postCustomEvent(String api, Map<String, dynamic> detail) {
    var map = {'detail': detail};
    var script = "window.dispatchEvent(new CustomEvent('$api', $map))";
    webController?.evaluateJavascript(source: script);
  }

  Map<String, dynamic Function(List<dynamic> arguments)> handlers = {};

  ///
  /// 监听自定义事件
  ///
  /// [param api] 事件名称
  /// [param callback] 事件回调
  ///
  /// web端处理监听自定义事件ts代码
  ///
  /// ```ts
  /// window['flutter_inappwebview']
  ///     .callHandler(api, ...args).then((result: any) => {
  ///         console.log('ResultString', JSON.stringify(result));
  ///     });
  /// ```
  void setupHandler(String api, dynamic Function(List<dynamic> args) callback) {
    handlers[api] = callback;
    webController?.addJavaScriptHandler(handlerName: api, callback: callback);
  }
}
