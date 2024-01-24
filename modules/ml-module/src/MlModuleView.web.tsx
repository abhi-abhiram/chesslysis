import * as React from 'react';

import { MlModuleViewProps } from './MlModule.types';

export default function MlModuleView(props: MlModuleViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
