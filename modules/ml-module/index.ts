import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to MlModule.web.ts
// and on native platforms to MlModule.ts
import MlModule from './src/MlModule';
import { ChangeEventPayload, MlModuleViewProps } from './src/MlModule.types';


export function details(): string {
  return MlModule.details();
}

export async function predict(image: string): Promise<string> {
  return await MlModule.predict(image);
}

export { MlModuleViewProps, ChangeEventPayload };
