import { NativeModule, requireNativeModule } from "expo";

declare class ExpoGbpingModule extends NativeModule {
  ping(url: string, timeout: number | null): Promise<number>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoGbpingModule>("ExpoGbping");
