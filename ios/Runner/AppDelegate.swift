import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: foreground presentation + tap handling.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    // workmanager: BGTaskScheduler handlers MUST be registered before this method returns.
    // With UIScene, plugins register later, so do it here explicitly.
    // The identifier must equal Info.plist BGTaskSchedulerPermittedIdentifiers and the
    // Dart constant `kWishlistCheckTask` (lib/core/background/background_tasks.dart).
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "vn.valvn.app.wishlistCheck",
      earliestBeginInSeconds: NSNumber(value: 6 * 60 * 60))
    WorkmanagerPlugin.registerLaunchHandlers()
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Background isolate for notification actions.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ValvnSecrets") else { return }
    let channel = FlutterMethodChannel(name: "valvn/secrets", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "privacy":
        SceneDelegate.secretPrivacyEnabled = (call.arguments as? Bool) ?? false
        result(nil)
      case "copy":
        guard let text = call.arguments as? String else {
          result(FlutterError(code: "invalid_argument", message: nil, details: nil))
          return
        }
        UIPasteboard.general.setItems([["public.utf8-plain-text": text]], options: [
          .localOnly: true, .expirationDate: Date(timeIntervalSinceNow: 45)
        ])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
