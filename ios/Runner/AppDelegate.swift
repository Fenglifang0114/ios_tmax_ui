import UIKit
import Flutter
#if canImport(Tmaxbackend)
import Tmaxbackend
#endif

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var backendStarted = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 应用启动时立即拉起 Go 后端引擎
    startGoBackend()

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let backendChannel = FlutterMethodChannel(name: "com.tmax.service/backend",
                                              binaryMessenger: controller.binaryMessenger)

    
    backendChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "startBackend" {
        self?.startGoBackend()
        result("iOS Go Backend Start Triggered")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startGoBackend() {
    guard !backendStarted else { return }
    backendStarted = true

    DispatchQueue.global(qos: .background).async {
      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
      let documentsDirectory = paths.first ?? NSTemporaryDirectory()
      let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "ios_device_id"
      let timeZone = TimeZone.current.identifier

      print("Starting Go Backend with Path: \(documentsDirectory), DeviceId: \(deviceId), TimeZone: \(timeZone)")

      #if canImport(Tmaxbackend)
      TmaxbackendStartBackend(documentsDirectory, deviceId, timeZone)
      #else
      print("Warning: Tmaxbackend framework not imported yet. Build with gomobile first.")
      #endif
    }
  }
}
