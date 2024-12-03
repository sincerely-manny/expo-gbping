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
- `timeout` (number) - The maximum time to wait for a response in milliseconds (optional).

# Usage

```typescript
import GBPing from 'expo-gbping';

const result: number = await GBPing.ping('https://google.com', 1000);
