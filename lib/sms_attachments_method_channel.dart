import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sms_attachments_platform_interface.dart';

/// An implementation of [SmsAttachmentsPlatform] that uses method channels.
class MethodChannelSmsAttachments extends SmsAttachmentsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_attachments');

  @override
  Future<void> send({
    required List<String> phones,
    required String text,
    List<String>? filePaths,
  }) async {
    return await methodChannel.invokeMethod('send', {
      'paths': filePaths,
      'recipientNumbers': phones,
      'message': text,
    });
  }

  @override
  Future<bool> canSendText() async {
    return await methodChannel.invokeMethod('canSendText');
  }

  @override
  Future<bool> canSendAttachments() async {
    return await methodChannel.invokeMethod('canSendAttachments');
  }
}
