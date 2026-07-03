import 'dart:io' show Platform;

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Column(
          children: [
            Text('Running on: ${Platform.version}\n'),
            Text('Running on: ${Platform.operatingSystem}\n'),
            Text('Running on: ${Platform.operatingSystemVersion}\n'),
            Text('Running on: ${Platform.localHostname}\n'),
            Text('Running on: ${Platform.localeName}\n'),
          ],
        ),
      ),
    );
  }
}
