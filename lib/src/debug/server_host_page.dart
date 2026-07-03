import 'package:flutter/material.dart';

import '../store/server_manager.dart';

class ServerHostPage extends StatelessWidget {
  ServerHostPage({super.key});

  final apiHostCt = TextEditingController();
  final h5HostCt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('切换网络环境')),
      body: SingleChildScrollView(
        physics: null,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text('切换网络环境', style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('服务器设置', style: TextStyle(fontSize: 16)),
                ),
                ...ServerManager.list.map((e) => _buildServer(context, e)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServer(BuildContext context, Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () async {
        if (s['env'] == 'custom') {
          await showDialog(
            context: context,
            builder: (context) => getCustomServerEditView(
              context,
              '自定义服务器',
              s['apiHost'] ?? '',
              s['h5Host'] ?? '',
              apiHostCt,
              h5HostCt,
              () {
                Navigator.of(context).pop();
              },
              () async {
                Navigator.of(context).pop();
                String apiPath = apiHostCt.text;
                if (apiPath.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('服务器地址不能为空!')));
                  return;
                }
                String h5Path = h5HostCt.text;
                if (h5Path.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('网页地址不能为空!')));
                  return;
                }
                ServerManager.saveServerInfo({
                  'env': 'custom',
                  'apiHost': apiPath,
                  'h5Host': h5Path,
                });
                Navigator.of(context).pop();
              },
            ),
          );
          Navigator.of(context).pop();
          return;
        }
        ServerManager.saveServerInfo(s);
        Navigator.of(context).pop();
      },
      child: SizedBox(
        width: 375,
        child: Card(
          margin: EdgeInsets.only(top: 15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ServerManager.env == s["env"] ? "(当前选择)" : ""}${s["env"] ?? ""}',
                  style: TextStyle(
                    fontSize: 18,
                    color: ServerManager.env == s['env']
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    s['apiHost'] ?? '未设置服务器地址',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    s['h5Host'] ?? '未设置网页地址',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getCustomServerEditView(
    BuildContext context,
    String title,
    String api,
    String h5,
    TextEditingController apiCt,
    TextEditingController h5Ct,
    Function() cancel,
    Function() accept, {
    String cancelText = '取消',
    String acceptText = '切换',
  }) {
    apiCt.text = api;
    h5Ct.text = h5;
    return Center(
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: Duration(milliseconds: 100),
        child: Card(
          child: Container(
            height: 212,
            width: 321,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 169,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withAlpha(230),
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                        child: TextField(
                          controller: apiCt,
                          maxLines: 1,
                          decoration: InputDecoration(
                            prefixIcon: const UnconstrainedBox(
                              child: Text('服务器: '),
                            ),
                            counterText: '',
                            hintText: api,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                        child: TextField(
                          controller: h5Ct,
                          maxLines: 1,
                          decoration: InputDecoration(
                            prefixIcon: const UnconstrainedBox(
                              child: Text('网页: '),
                            ),
                            counterText: '',
                            hintText: h5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: Colors.black.withAlpha(25)),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: cancel,
                        child: SizedBox(
                          width: 160,
                          child: Text(
                            cancelText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(width: 1, color: Colors.black.withAlpha(25)),
                      GestureDetector(
                        onTap: accept,
                        child: SizedBox(
                          width: 160,
                          child: Text(
                            acceptText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
