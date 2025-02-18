import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sms_attachments/sms_attachments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _canSendAttachments = 'Unknown';

  @override
  void initState() {
    super.initState();
    initCanSendAttachmentsState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initCanSendAttachmentsState() async {
    String canSendAttachments;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      canSendAttachments =
          (await SmsAttachments.canSendAttachments()).toString();
    } on PlatformException {
      canSendAttachments = 'Failed to get canSendAttachments.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _canSendAttachments = canSendAttachments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Can send attachments: $_canSendAttachments\n'),
        ),
      ),
    );
  }
}
