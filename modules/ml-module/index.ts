import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to MlModule.web.ts
// and on native platforms to MlModule.ts
import MlModule from './src/MlModule';
import MlModuleView from './src/MlModuleView';
import { ChangeEventPayload, MlModuleViewProps } from './src/MlModule.types';

// Get the native constant value.
export const PI = MlModule.PI;

export function hello(): string {
  return MlModule.hello();
}

export async function setValueAsync(value: string) {
  return await MlModule.setValueAsync(value);
}

const emitter = new EventEmitter(MlModule ?? NativeModulesProxy.MlModule);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { MlModuleView, MlModuleViewProps, ChangeEventPayload };
