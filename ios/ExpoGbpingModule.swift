import ExpoModulesCore
import GBPing

public class ExpoGbpingModule: Module {
  private var pingQueue: [PingOperation] = []
  private var isPinging: Bool = false

  public func definition() -> ModuleDefinition {
    Name("ExpoGbping")

    AsyncFunction("ping") {
      (url: String, timeout: TimeInterval?, promise: Promise) in
      let operation = PingOperation(
        url: url, timeout: timeout, promise: promise)
      self.pingQueue.append(operation)
      self.processQueue()
    }
  }

  private func processQueue() {
    guard !isPinging, let operation = pingQueue.first else {
      return
    }

    isPinging = true
    let ping = GBPing()
    ping.host = operation.url
    if let timeout = operation.timeout {
      ping.timeout = timeout
    }
    ping.pingPeriod = 0.9

    let delegate = PingDelegate(
      promise: operation.promise,
      cleanup: { [weak self] in
        guard let self = self else { return }
        self.isPinging = false
        self.pingQueue.removeFirst()
        self.processQueue()
      }
    )
    ping.delegate = delegate

    ping.setup { [weak self] success, error in
      guard self != nil else { return }
      if success {
        ping.startPinging()

        DispatchQueue.main.asyncAfter(
          deadline: .now() + (operation.timeout ?? 1.0)
        ) {
          // Explicitly check if ping is still active
          if ping.isPinging {
            ping.stop()
            delegate.pingTimeoutManuallyTriggered()
          }
        }
      } else {
        operation.promise.reject(
          "PING_SETUP_ERROR",
          error?.localizedDescription ?? "Unknown error during setup.")
        delegate.cleanupIfNeeded()
      }
    }
  }
}

private class PingOperation {
  let url: String
  let timeout: TimeInterval?
  let promise: Promise

  init(url: String, timeout: TimeInterval?, promise: Promise) {
    self.url = url
    self.timeout = timeout
    self.promise = promise
  }
}

private class PingDelegate: NSObject, GBPingDelegate {
  private let promise: Promise
  private let cleanup: () -> Void
  private var didCleanup: Bool = false

  init(promise: Promise, cleanup: @escaping () -> Void) {
    self.promise = promise
    self.cleanup = cleanup
  }

  func cleanupIfNeeded() {
    if !didCleanup {
      didCleanup = true
      cleanup()
    }
  }

  func pingTimeoutManuallyTriggered() {
    promise.reject("PING_TIMEOUT", "Ping timed out (forcibly).")
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
    promise.resolve(summary.rtt * 1000)
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
    promise.reject("PING_TIMEOUT", "Ping timed out: \(summary)")
    cleanupIfNeeded()
  }

  func ping(_ pinger: GBPing, didFailWithError error: Error) {
    promise.reject(
      "PING_ERROR", "Ping failed with error: \(error.localizedDescription)")
    cleanupIfNeeded()
  }

  func ping(
    _ pinger: GBPing, didFailToSendPingWith summary: GBPingSummary, error: Error
  ) {
    promise.reject(
      "PING_SEND_ERROR", "Failed to send ping: \(error.localizedDescription)")
    cleanupIfNeeded()
  }
}
