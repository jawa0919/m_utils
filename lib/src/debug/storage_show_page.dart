import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dio_log_plus/dio_log_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageShowPage extends StatefulWidget {
  const StorageShowPage({super.key});

  @override
  State<StorageShowPage> createState() => _StorageShowPageState();
}

class _StorageShowPageState extends State<StorageShowPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (c, s) {
        final sp = s.data;
        if (sp == null) return const CircularProgressIndicator();
        List<String> keys = sp.getKeys().toList();
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text('存储 - ${keys.length}条'),
          ),
          body: ListView.builder(
            itemCount: keys.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: InkWell(
                  child: const Icon(Icons.delete),
                  onTap: () async {
                    await sp.remove(keys[index]);
                    keys = sp.getKeys().toList();
                    setState(() {});
                  },
                ),
                title: Text(keys[index], style: const TextStyle(fontSize: 20)),
                trailing: const InkWell(child: Icon(Icons.navigate_next)),
                onTap: () {
                  String value = sp.get(keys[index]).toString();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return _valueJsonView(context, keys[index], value);
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _valueJsonView(BuildContext context, String key, String value) {
    return Scaffold(
      appBar: AppBar(
        title: Text(key),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copy To Clipboard Success')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: value.contains('{')
            ? SingleChildScrollView(
                child: JsonView(json: jsonDecode(value), fontSize: 20),
              )
            : Text(value),
      ),
    );
  }
}
