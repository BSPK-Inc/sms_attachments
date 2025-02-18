import 'sms_attachments_platform_interface.dart';

class SmsAttachments {
  static Future<void> send({
    required List<String> phones,
    required String text,
    List<String>? filePaths,
  }) {
    return SmsAttachmentsPlatform.instance.send(
      phones: phones,
      text: text,
      filePaths: filePaths,
    );
  }

  static Future<bool> canSendText() {
    return SmsAttachmentsPlatform.instance.canSendText();
  }

  static Future<bool> canSendAttachments() {
    return SmsAttachmentsPlatform.instance.canSendAttachments();
  }
}
