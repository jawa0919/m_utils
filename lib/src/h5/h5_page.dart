import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:signals/signals_flutter.dart';

import '../view/setting_view.dart';
import 'h5_logic.dart';

class H5Page extends StatefulWidget {
  static const String routeName = '/h5';
  static bool debugFlag = !bool.fromEnvironment('dart.vm.product');
  final String url;
  const H5Page({super.key, required this.url});

  static Future<T?> start<T>(BuildContext context, String url) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => H5Page(url: url)),
    );
  }

  @override
  State<H5Page> createState() => _H5PageState();
}

class _H5PageState extends State<H5Page>
    with SignalsMixin, WidgetsBindingObserver {
  final logic = H5Logic();

  final GlobalKey _webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    logic.onPageCreated();
    debugPrint('h5_page.dart~initState: ${widget.url}');
    logic.initialUrl.value = widget.url;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logic.onPageMounted(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    logic.onPageDestroyed(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        debugPrint('h5_page.dart~onPopInvokedWithResult: $didPop $result');
        if (didPop) return;
        bool webBack = await logic.webController?.canGoBack() ?? false;
        if (webBack) {
          await logic.webController?.goBack();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        drawer: H5Page.debugFlag ? _buildDebugDrawer(context) : null,
        appBar: AppBar(backgroundColor: Colors.transparent, toolbarHeight: 0),
        bottomNavigationBar: Builder(
          builder: (context) {
            return Container(
              height: MediaQuery.of(context).padding.bottom,
              color: Colors.transparent,
            );
          },
        ),
        extendBody: logic.isFullScreen.watch(context),
        extendBodyBehindAppBar: logic.isFullScreen.watch(context),
        body: Stack(
          children: <Widget>[
            _buildBackgroundView(context),
            _buildInAppWebView(context),
            _buildForegroundView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundView(BuildContext context) {
    return Container(color: Colors.transparent);
  }

  Widget _buildForegroundView(BuildContext context) {
    if (logic.status.value == 'normal') {
      return IgnorePointer(child: Container(color: Colors.transparent));
    } else if (logic.status.value == 'loading') {
      // return Center(child: CircularProgressIndicator());
      return IgnorePointer(child: Container(color: Colors.transparent));
    } else if (logic.status.value.startsWith('error')) {
      final errorMessage = logic.status.value.replaceFirst('error.', '');
      return Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        height: double.maxFinite,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText('加载失败：$errorMessage'),
            Padding(
              padding: const EdgeInsets.fromLTRB(38.0, 18.0, 38.0, 18.0),
              child: SelectableText(logic.currentUrl.value),
            ),
            ElevatedButton(
              onPressed: () {
                logic.webController?.reload();
              },
              child: Text('重试'),
            ),
          ],
        ),
      );
    } else {
      return IgnorePointer(child: Container(color: Colors.transparent));
    }
  }

  Widget _buildInAppWebView(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      initialSettings: logic.initialSettings,
      initialUrlRequest: logic.initialUrlRequest.watch(context),
      onWebViewCreated: (controller) async {
        logic.webController = controller;
        logic.addHandler();
      },
      onLoadStart: (controller, url) async {
        debugPrint('onLoadStart: $url');
        logic.status.value = 'loading';
        logic.currentUrl.value = url.toString();
      },
      onProgressChanged: (controller, progress) {
        debugPrint('onProgressChanged: $progress');
      },
      onLoadStop: (controller, url) {
        debugPrint('onLoadStop: $url');
        if (!logic.status.value.startsWith('error')) {
          logic.status.value = 'normal';
        }
        logic.currentUrl.value = url.toString();
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        debugPrint('shouldOverrideUrlLoading: $navigationAction');
        switch (navigationAction.request.url?.scheme) {
          case 'http':
            return NavigationActionPolicy.ALLOW;
          case 'https':
            return NavigationActionPolicy.ALLOW;
          case 'tel':
            return NavigationActionPolicy.CANCEL;
          case 'sms':
            return NavigationActionPolicy.CANCEL;
          case 'weixin':
            return NavigationActionPolicy.CANCEL;
          case 'alipays':
            return NavigationActionPolicy.CANCEL;
          default:
            return NavigationActionPolicy.CANCEL;
        }
      },
      onReceivedError: (controller, url, error) {
        debugPrint('onReceivedError: ${error.toString()}');
        if (error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST) {
          logic.status.value = 'error.CANNOT_CONNECT_TO_HOST';
        }
        if (error.type == WebResourceErrorType.NETWORK_CONNECTION_LOST) {
          logic.status.value = 'error.NETWORK_CONNECTION_LOST';
        }
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint('onReceivedHttpError: $request $errorResponse');
        // 网页上的request请求的错误
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        debugPrint('onUpdateVisitedHistory:  $url $isReload');
        logic.currentUrl.value = url.toString();
      },
      // onJsAlert: (controller, JsAlertRequest jsAlertRequest) async {
      //   debugPrint('onJsAlert: $jsAlertRequest');
      //   return JsAlertResponse()..handledByClient = true;
      //   // var map = jsAlertRequest.message ?? {};
      //   // var title = map.title ?? "";
      //   // var message = map.message ?? "";
      //   // var confirm = map.confirm ?? "";
      //   // var cancel = map.cancel ?? "";
      // },
      // onJsConfirm: (controller, JsConfirmRequest jsConfirmRequest) async {
      //   debugPrint('onJsConfirm: $jsConfirmRequest');
      //   return JsConfirmResponse();
      // },
      // onJsPrompt: (controller, JsPromptRequest jsPromptRequest) async {
      //   debugPrint('onJsPrompt: $jsPromptRequest');
      //   return JsPromptResponse();
      // },
    );
  }

  Widget? _buildDebugDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          TextButton(
            onPressed: () => SettingView.start(context),
            child: Text('H5Page'),
          ),
          ListTile(
            title: Text('URL'),
            subtitle: SelectableText(logic.currentUrl.watch(context)),
            onTap: () {},
          ),
          ListTile(
            title: Text('后退'),
            onTap: () async {
              if (await logic.webController?.canGoBack() == true) {
                logic.webController?.goBack();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.maybeOf(
                  context,
                )?.showSnackBar(SnackBar(content: Text('无法后退')));
              }
            },
          ),
          ListTile(
            title: Text('前进'),
            onTap: () {
              logic.webController?.goForward();
            },
          ),
          ListTile(
            title: Text('刷新'),
            onTap: () {
              logic.webController?.reload();
            },
          ),
        ],
      ),
    );
  }
}
