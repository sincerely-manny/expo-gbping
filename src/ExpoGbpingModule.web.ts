import { registerWebModule, NativeModule } from 'expo';

import { ExpoGbpingModuleEvents } from './ExpoGbping.types';

class ExpoGbpingModule extends NativeModule<ExpoGbpingModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoGbpingModule);
