import UIKit
import Flutter
import Network
#if canImport(Tmaxbackend)
import Tmaxbackend
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backendStarted = false
  private var localNetworkBrowser: NWBrowser?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 应用启动时立即拉起 Go 后端引擎
    startGoBackend()
    triggerLocalNetworkPermissionPrompt()

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

  // 触发 iOS 14+ 本地网络权限授权弹窗
  private func triggerLocalNetworkPermissionPrompt() {
    if #available(iOS 14.0, *) {
      let browser = NWBrowser(for: .bonjour(type: "_tmax-scale._tcp", domain: nil), using: .tcp)
      self.localNetworkBrowser = browser
      browser.start(queue: .main)

      // 探测 3 秒后停止，避免长期占用电量
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
        self?.localNetworkBrowser?.cancel()
        self?.localNetworkBrowser = nil
      }
    }
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
