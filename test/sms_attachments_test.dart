import 'package:flutter_test/flutter_test.dart';
import 'package:sms_attachments/sms_attachments.dart';
import 'package:sms_attachments/sms_attachments_platform_interface.dart';
import 'package:sms_attachments/sms_attachments_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmsAttachmentsPlatform
    with MockPlatformInterfaceMixin
    implements SmsAttachmentsPlatform {
  @override
  Future<bool> canSendAttachments() => Future.value(true);

  @override
  Future<bool> canSendText() => Future.value(true);

  @override
  Future<void> send(
      {required List<String> phones,
      required String text,
      List<String>? filePaths}) {
    return Future.value();
  }
}

void main() {
  final SmsAttachmentsPlatform initialPlatform =
      SmsAttachmentsPlatform.instance;

  test('$MethodChannelSmsAttachments is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmsAttachments>());
  });

  test('canSendAttachments', () async {
    MockSmsAttachmentsPlatform fakePlatform = MockSmsAttachmentsPlatform();
    SmsAttachmentsPlatform.instance = fakePlatform;

    expect(await SmsAttachments.canSendAttachments(), true);
  });
}
