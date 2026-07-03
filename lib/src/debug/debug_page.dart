import 'package:flutter/material.dart';

import 'package:dio_log_plus/dio_log_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../m_utils.dart';
import '../h5/h5_page.dart';
import '../util/media_util.dart';
import '../util/share_util.dart';
import '../view/qr_scan_view.dart';
import 'server_host_page.dart';
import 'storage_show_page.dart';
import 'theme_color_show_page.dart';
import 'url_schemes_page.dart';

class DebugPage extends StatefulWidget {
  static bool debugFlag = !MUtils.isProduct;
  const DebugPage({super.key});

  static void start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DebugPage()),
    );
  }

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  var f = TextEditingController(text: 'https://flutter.cn/');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showDebugBtn(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DebugPage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      extendBody: false,
      body: Card(
        margin: const EdgeInsets.all(16),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              TextButton(
                child: const Text('更换服务器'),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ServerHostPage()),
                  );
                },
              ),
              TextButton(
                child: const Text('存储展示'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StorageShowPage(),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('颜色展示'),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ThemeColorShowPage(),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('常用快捷跳转'),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const URLSchemesPage(),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('js bridge debug'),
                onPressed: () async {
                  final localhostServer = InAppLocalhostServer(
                    port: 14399,
                    documentRoot: 'packages/wj_utils/assets/js_bridge_debug/',
                  );
                  await localhostServer.start();
                  String url = 'http://localhost:14399/index.html';
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => H5Page(url: url),
                        ),
                      )
                      .then((_) {
                        localhostServer.close();
                      });
                },
              ),
              Builder(
                builder: (context) {
                  return ListTile(
                    leading: IconButton(
                      onPressed: () {
                        ShareUtil.openSystemBrowser(f.text);
                      },
                      onLongPress: () {
                        final imgBytes = QrScanView.qrPng(f.text);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.memory(imgBytes),
                              ElevatedButton(
                                child: const Text('保存'),
                                onPressed: () async {
                                  await MediaUtil.saveImageBytesToPhotosAlbum(
                                    imgBytes,
                                    'qr_code_${DateTime.now().toString()}.png',
                                  ).then((value) {
                                    if (value.isSuccess) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('save success')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'save failed ${value.errorMessage}',
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.web),
                    ),
                    title: Text('浏览器'),
                    subtitle: TextField(controller: f),
                    trailing: IconButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => H5Page(url: f.text),
                          ),
                        );
                      },
                      icon: Icon(Icons.near_me),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text('二维码扫描'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScanView()),
                  ).then((value) {
                    if (value != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('scanning result:value=$value')),
                      );
                    }
                  });
                },
              ),
              TextButton(child: const Text('消息推送'), onPressed: () async {}),
              TextButton(child: const Text('文件上传测试'), onPressed: () async {}),
              TextButton(child: const Text('文件下载测试'), onPressed: () async {}),
              SizedBox(),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
