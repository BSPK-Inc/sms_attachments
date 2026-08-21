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
    
    guard let presenter = topmostViewController() else {
      // Fail closed. The result is only delivered from the compose controller's
      // delegate, so returning without presenting and without answering here left
      // the Dart future pending forever.
      result(FlutterError(code: "NO_PRESENTER",
                          message: "No view controller available to present the message composer",
                          details: nil))
      return
    }

    self.result = result
    presenter.present(messageController, animated: true, completion: nil)
  }

  /// The view controller to present from.
  ///
  /// `UIApplication.shared.delegate?.window` is nil once the app adopts the
  /// UIScene lifecycle: the window belongs to the scene delegate, not the app
  /// delegate. Walk the connected scenes instead, and then down through anything
  /// already presented, since presenting on a controller that is itself presenting
  /// does nothing.
  private func topmostViewController() -> UIViewController? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }

    let window = windows.first { $0.isKeyWindow } ?? windows.first
    guard var controller = window?.rootViewController else {
      return nil
    }

    while let presented = controller.presentedViewController {
      controller = presented
    }
    return controller
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
