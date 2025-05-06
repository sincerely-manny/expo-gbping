# expo-gbping

Expo module wrapper for [GBPing Swift Library](https://github.com/lmirosevic/GBPing)

*TL;DR:* This module allows you to ping hosts and get accurate round-trip timing results.

🍎 iOS only.

# Installation

```
npx expo install expo-gbping
```

### Configure for iOS

Run `npx pod-install` after installing the npm package.

# API

## `ping(host: string, timeout?: number): Promise<number>`
Pings the specified host and returns the round-trip time in milliseconds.
Parameters:
- `host` (string) - The host to ping.
- `timeout` (number) - The maximum time to wait for a response in milliseconds (optional, default is 1000).

## `startPinging(options: PingingOptions): void`
Starts pinging the specified host (or broadcast range) and emits events for each ping result.
Parameters:
- `options` (PingOptions) - The options for pinging.
  - `url` (string) - The host to ping.
  - `timeout` (number) - The maximum time to wait for a response in milliseconds (optional, default is 1000).
  - `interval` (number) - The interval between pings in milliseconds (optional, default is 1000).
  - `onPing` (function) - A callback function that is called with the ping result.
    - `event` `(result: PingResult) => void`- The ping event.
      - `event.event` (string) - The event type ("pingTimeoutManuallyTriggered", "pingReceived", "pingTimeout", "pingFailed", "pingSendFailed").
      - `event.sequenceNumber` (number) - The sequence number of the ping.
      - `event.payloadSize` (number) - The size of the payload in bytes.
      - `event.ttl` (number) - The time-to-live value of the ping.
      - `event.host` (string) - The host that responded to the ping.
      - `event.sendDate` (string) - ISO8601 formatted date string of when the ping was sent.
      - `event.receiveDate` (string) - ISO8601 formatted date string of when the ping was received.
      - `event.status` (number) - The status code of the ping (0 - 'Pending', 1 - 'Success', 2 - 'Fail').
      - `event.rtt` (number) - The round-trip time in milliseconds.
      - `event.error` (string) - The error message if the ping failed.

# Usage

```typescript
import GBPing from 'expo-gbping';

const result: number = await GBPing.ping('https://google.com', 1000);


GBPing.startPinging({
  url: "192.168.1.255",
  timeout: timeout,
  interval: 1000,
  onPing: (event) => {
    console.log(JSON.stringify(event, null, 2));
    if (event.event === 'pingReceived') {
      setResult((prev) => `${prev}\n✅ ${event.sequenceNumber}. ${event.host}: ${event.rtt?.toFixed(2)}ms `);
    } else {
      setResult((prev => `${prev}\n❌ ${event.error}`));
    }
  },
});

GBPing.stopPinging();

```
