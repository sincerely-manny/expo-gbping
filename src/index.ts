// Reexport the native module. On web, it will be resolved to ExpoGbpingModule.web.ts
// and on native platforms to ExpoGbpingModule.ts
import Module from "./ExpoGbpingModule";

/*
 * Ping the given URL.
 * @param url The URL to ping.
 * @param timeout The timeout in milliseconds.
 * @returns The ping in milliseconds.
 * @throws If the ping fails.
 */
function ping(url: string, timeout?: number) {
  const t = timeout === undefined ? null : timeout / 1000;
  return Module.ping(url, t);
}

export default {
  ping,
};
