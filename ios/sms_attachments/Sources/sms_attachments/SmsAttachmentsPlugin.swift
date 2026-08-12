import Flutter
import UIKit
import MessageUI

public class SmsAttachmentsPlugin: NSObject, FlutterPlugin {
  static let macMessagesScheme = "sms://"

  var result: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sms_attachments", binaryMessenger: registrar.messenger())
    let instance = SmsAttachmentsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "send":
      guard let args = call.arguments as? [String: Any],
            let recipients = args["recipientNumbers"] as? [String],
            let message = args["message"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
        return
      }
      let paths = (args["paths"] as? [String]) ?? []
      send(paths: paths, recipients: recipients, message: message, result: result)
    
    case "canSendText":
      result(canSendText())

    case "canSendAttachments":
      result(canSendAttachments())

    case "isRunningOnMac":
      result(isRunningOnMac)
    
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func canSendAttachments() -> Bool {
    if isRunningOnMac {
      return false
    }
    return MFMessageComposeViewController.canSendAttachments()
  }

  private func canSendText() -> Bool {
    if isRunningOnMac {
      guard let url = URL(string: SmsAttachmentsPlugin.macMessagesScheme) else {
        return false
      }
      return UIApplication.shared.canOpenURL(url)
    }
    return MFMessageComposeViewController.canSendText()
  }
  
  private func send(paths: [String], recipients: [String], message: String, result: @escaping FlutterResult) {
    guard !isRunningOnMac, canSendText() else {
      result(FlutterError(code: "UNAVAILABLE", message: "SMS services are not available", details: nil))
      return
    }
    
    let messageController = MFMessageComposeViewController()
    messageController.messageComposeDelegate = self
    messageController.recipients = recipients
    messageController.body = message
    
    if canSendAttachments() {
      for path in paths {
        let fileURL = URL(fileURLWithPath: path)
        let res = messageController.addAttachmentURL(fileURL, withAlternateFilename: nil)
        print("\(fileURL) result: \(res)")
      }
    }
    
    self.result = result
    if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
      rootViewController.present(messageController, animated: true, completion: nil)
    }
    
  }

  private var isRunningOnMac: Bool {
    return ProcessInfo.processInfo.isiOSAppOnMac;
  }
}

extension SmsAttachmentsPlugin: MFMessageComposeViewControllerDelegate {
  
  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true, completion: nil)
    switch result {
    case .sent:
      self.result?(true)
    default:
      self.result?(false)
    }
  }
  
}
