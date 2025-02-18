import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sms_attachments_method_channel.dart';

abstract class SmsAttachmentsPlatform extends PlatformInterface {
  /// Constructs a SmsAttachmentsPlatform.
  SmsAttachmentsPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsAttachmentsPlatform _instance = MethodChannelSmsAttachments();

  /// The default instance of [SmsAttachmentsPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmsAttachments].
  static SmsAttachmentsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmsAttachmentsPlatform] when
  /// they register themselves.
  static set instance(SmsAttachmentsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> send({
    required List<String> phones,
    required String text,
    List<String>? filePaths,
  }) {
    throw UnimplementedError('send() has not been implemented.');
  }

  Future<bool> canSendText() {
    throw UnimplementedError('canSendText() has not been implemented.');
  }

  Future<bool> canSendAttachments() {
    throw UnimplementedError('canSendAttachments() has not been implemented.');
  }
}
