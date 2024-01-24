import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { MlModuleViewProps } from './MlModule.types';

const NativeView: React.ComponentType<MlModuleViewProps> =
  requireNativeViewManager('MlModule');

export default function MlModuleView(props: MlModuleViewProps) {
  return <NativeView {...props} />;
}
