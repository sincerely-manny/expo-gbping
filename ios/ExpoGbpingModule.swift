import ExpoModulesCore
import Foundation

//import GBPing

public final class ExpoGbpingModule: Module {
  private var pingQueue: [PingOperation] = []
  private var isPinging: Bool = false
  private var ping: GBPing?
  private var pingDelegate: GBPingDelegate?

  public func definition() -> ModuleDefinition {
    Name("ExpoGbping")
    Events("onPingEvent")

    AsyncFunction("ping") {
      (url: String, timeout: TimeInterval?, promise: Promise) in
      let operation = PingOperation(
        url: url, timeout: timeout, promise: promise)
      self.pingQueue.append(operation)
      self.processQueue()
    }

    AsyncFunction("startPinging") {
      (url: String, timeout: TimeInterval?, interval: TimeInterval?) in
      self.startPinging(url: url, timeout: timeout, interval: interval)
    }

    AsyncFunction("stopPinging") {
      self.stopPinging()
    }

  }

  private func startPinging(url: String, timeout: TimeInterval?, interval: TimeInterval?) {
    guard !isPinging else { return }
    isPinging = true
    ping = GBPing()
    print("Starting pinging with URL: \(url)")
    guard let ping else { return }
    print("Pinging host: \(url)")
    ping.host = url
    if let timeout { ping.timeout = timeout }
    if let interval { ping.pingPeriod = interval }
    pingDelegate = SeriesPingDelegate(sendEvent: sendEvent)
    ping.delegate = pingDelegate

    ping.setup { [weak self] success, error in
      guard let self = self else { return }
      if success {
        ping.startPinging()
        print("Ping started successfully")
        self.sendEvent(
          "onPingEvent",
          [
            "event": "pingStarted",
            "host": url,
          ])
      } else {
        print("Failed to start ping: \(error?.localizedDescription ?? "Unknown error")")
        sendEvent(
          "onPingEvent",
          [
            "event": "pingFailed",
            "error": error?.localizedDescription ?? "Unknown error",
          ])
        self.isPinging = false
        self.ping = nil
      }
    }
  }

  private func stopPinging() {
    guard isPinging else { return }
    isPinging = false
    ping?.stop()
    ping = nil
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

    let delegate = SinglePingDelegate(
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

private final class PingOperation {
  let url: String
  let timeout: TimeInterval?
  let promise: Promise

  init(url: String, timeout: TimeInterval?, promise: Promise) {
    self.url = url
    self.timeout = timeout
    self.promise = promise
  }
}

private class SinglePingDelegate: NSObject, GBPingDelegate {
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

private final class SeriesPingDelegate: NSObject, GBPingDelegate {
  private let sendEvent: (_ eventName: String, _ body: [String: Any?]) -> Void

  init(sendEvent: @escaping (_ eventName: String, _ body: [String: Any?]) -> Void) {
    self.sendEvent = sendEvent
  }

  func pingTimeoutManuallyTriggered() {
    print("⚠️ Ping timeout manually triggered")
    sendEvent("onPingEvent", ["event": "pingTimeoutManuallyTriggered"])
  }

  func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
    print("✅ Ping received reply with summary: \(summary)")
    sendEvent(
      "onPingEvent",
      [
        "event": "pingReceived",
        "sequenceNumber": summary.sequenceNumber,
        "payloadSize": summary.payloadSize,
        "ttl": summary.ttl,
        "host": summary.host,
        "sendDate": summary.sendDate?.ISO8601Format(),
        "receiveDate": summary.receiveDate?.ISO8601Format(),
        "status": summary.status.rawValue,
        "rtt": summary.rtt * 1000,
      ])
  }

  func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
    sendEvent(
      "onPingEvent",
      [
        "event": "pingTimeout",
        "sequenceNumber": summary.sequenceNumber,
        "payloadSize": summary.payloadSize,
        "ttl": summary.ttl,
        "host": summary.host,
        "sendDate": summary.sendDate?.ISO8601Format(),
        "receiveDate": summary.receiveDate?.ISO8601Format(),
        "status": summary.status.rawValue,
        "rtt": summary.rtt * 1000,
      ])
  }

  func ping(_ pinger: GBPing, didFailWithError error: Error) {
    sendEvent(
      "onPingEvent",
      [
        "event": "pingFailed",
        "error": error.localizedDescription,
      ])
  }

  func ping(
    _ pinger: GBPing, didFailToSendPingWith summary: GBPingSummary, error: Error
  ) {
    sendEvent(
      "onPingEvent",
      [
        "event": "pingSendFailed",
        "summary": summary,
        "error": error.localizedDescription,
      ])
  }
}
