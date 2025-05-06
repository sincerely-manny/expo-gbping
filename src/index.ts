// Reexport the native module. On web, it will be resolved to ExpoGbpingModule.web.ts
// and on native platforms to ExpoGbpingModule.ts
import type { EventSubscription } from "expo-modules-core";
import Module, { PingStatus, type PingResult } from "./ExpoGbpingModule";

let subscription: EventSubscription | null = null;

/*
 * Ping the given URL.
 * @param url The URL to ping.
 * @param timeout The timeout in milliseconds (optional, default is 1000ms).
 * @returns The ping in milliseconds.
 * @throws If the ping fails.
 */
function ping(url: string, timeout?: number) {
  const t = timeout === undefined ? 1 : timeout / 1000;
  return Module.ping(url, t);
}

function addListener(callback?: (event: PingResult) => void) {
  return Module.addListener('onPingEvent', callback ?? (() => {}));
}

function startPinging(params: {
  url: string,
  timeout?: number,
  interval?: number,
  onPing?: (event: PingResult) => void
}) {
  const { url, timeout, interval, onPing } = params;
  const t = timeout === undefined ? undefined : timeout / 1000;
  const i = interval === undefined ? undefined : interval / 1000;
  subscription = addListener(onPing);
  Module.startPinging(url, t, i);
}

function stopPinging() {
  subscription?.remove();
  subscription = null;
  Module.stopPinging();
}


export default {
  ping,
  startPinging,
  stopPinging,
};

export { PingStatus };
export type { PingResult };

