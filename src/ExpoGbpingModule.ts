import { NativeModule, requireNativeModule } from "expo";

export enum PingStatus {
  'Pending',
  'Success',
  'Failure',
}

export type PingResult = {
  "event": string,
  "sequenceNumber"?: number,
  "payloadSize"?: number,
  "ttl"?: number,
  "host"?: string,
  "sendDate"?: string,
  "receiveDate"?: string,
  "status"?: PingStatus,
  "rtt"?: number,
  "error"?: string,
}

export type PingEvents = {
  onPingEvent(event: PingResult): void;
}

declare class ExpoGbpingModule extends NativeModule<PingEvents> {
  ping(url: string, timeout: number | null): Promise<number>;
}


// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoGbpingModule>("ExpoGbping");
