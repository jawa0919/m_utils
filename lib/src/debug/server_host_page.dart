import 'package:flutter/material.dart';

import '../store/server_manager.dart';

class ServerHostPage extends StatelessWidget {
  const ServerHostPage({super.key});

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
                ...ServerManager.map.keys.map((e) => _buildServer(context, e)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServer(BuildContext context, String env) {
    final info = ServerManager.map[env]!;
    return GestureDetector(
      onTap: () async {
        if (env == 'custom') {
          _buildCustomServerEditView(context, info);
          return;
        }
        ServerManager.saveServerInfo(env, info);
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
                  '${ServerManager.env == env ? "(当前选择)" : ""}${env}',
                  style: TextStyle(
                    fontSize: 18,
                    color: ServerManager.env == env
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                ...info.keys.map((k) {
                  final v = info[k];
                  return Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      '${k}: ${v ?? '未设置$k'}',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }),
                FilledButton(
                  onPressed: () {
                    _buildCustomServerEditView(context, info);
                  },
                  child: Text('Duplicate Custom'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _buildCustomServerEditView(
    BuildContext context,
    Map<String, String> info,
  ) async {
    final ctMap = {
      for (var e in info.keys) e: TextEditingController(text: info[e] ?? ''),
    };
    await showDialog(
      context: context,
      builder: (context) => getCustomServerEditView(
        context,
        '自定义服务器',
        ctMap,
        () {
          Navigator.of(context).pop();
        },
        () async {
          for (var e in ctMap.keys) {
            if (ctMap[e]?.text.isEmpty ?? true) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${e}不能为空!')));
              return;
            }
          }
          ServerManager.saveServerInfo('custom', {
            for (var e in ctMap.keys) e: ctMap[e]?.text ?? '',
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget getCustomServerEditView(
    BuildContext context,
    String title,
    Map<String, TextEditingController> ctList,
    Function() cancel,
    Function() accept, {
    String cancelText = '取消',
    String acceptText = '切换',
  }) {
    return Center(
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: Duration(milliseconds: 100),
        child: SingleChildScrollView(
          child: Card(
            child: Container(
              width: 321,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withAlpha(230),
                      fontSize: 18,
                    ),
                  ),
                  ...ctList.keys.map(
                    (k) => Padding(
                      padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                      child: TextField(
                        controller: ctList[k]!,
                        maxLines: 1,
                        decoration: InputDecoration(
                          prefixIcon: UnconstrainedBox(child: Text('$k: ')),
                          counterText: '',
                          hintText: k,
                        ),
                      ),
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
      ),
    );
  }
}
