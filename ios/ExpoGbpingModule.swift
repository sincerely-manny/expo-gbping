import ExpoModulesCore
import GBPing

public class ExpoGbpingModule: Module {
  private var ping: GBPing?
  private var pingDelegate: PingDelegate?

  public func definition() -> ModuleDefinition {
    Name("ExpoGbping")

    AsyncFunction("ping") {
      (url: String, timeout: TimeInterval?, promise: Promise) in

      self.ping = GBPing()
      guard let ping = self.ping else {
        promise.reject(
          "PING_INIT_ERROR", "Failed to initialize GBPing instance.")
        return
      }

      let delegate = PingDelegate(promise: promise)
      self.pingDelegate = delegate
      ping.delegate = delegate

      ping.host = url
      if let timeout {
        ping.timeout = timeout
      }

      ping.setup { [weak self] success, error in
        if success {
          ping.startPinging()

          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ping.stop()
            self?.ping = nil
            self?.pingDelegate = nil
          }
        } else {
          promise.reject(
            "PING_SETUP_ERROR",
            error?.localizedDescription ?? "Unknown error during setup.")
          self?.ping = nil
          self?.pingDelegate = nil
        }
      }
    }
  }
}

private class PingDelegate: NSObject, GBPingDelegate {
  private let promise: Promise

  init(promise: Promise) {
    self.promise = promise
  }

  func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
    promise.resolve(summary.rtt * 1000)
  }

  func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
    promise.reject("PING_TIMEOUT", "Ping timed out: \(summary)")
  }

  func ping(_ pinger: GBPing, didFailWithError error: Error) {
    promise.reject(
      "PING_ERROR", "Ping failed with error: \(error.localizedDescription)")
  }
}
