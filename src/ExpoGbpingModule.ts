import { NativeModule, requireNativeModule } from 'expo';

import { ExpoGbpingModuleEvents } from './ExpoGbping.types';

declare class ExpoGbpingModule extends NativeModule<ExpoGbpingModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoGbpingModule>('ExpoGbping');
