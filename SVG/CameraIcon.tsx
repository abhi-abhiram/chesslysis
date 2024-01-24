import * as React from 'react';
import Svg, { SvgProps, Path } from 'react-native-svg';
const CameraIcon = (props: SvgProps) => (
  <Svg width={16} height={15} fill='none' {...props}>
    <Path
      stroke='#161A30'
      strokeLinecap='round'
      strokeLinejoin='round'
      strokeWidth={1.5}
      d='M8 10a1.875 1.875 0 1 0 0-3.75A1.875 1.875 0 0 0 8 10Z'
    />
    <Path
      stroke='#161A30'
      strokeLinecap='round'
      strokeLinejoin='round'
      strokeWidth={1.5}
      d='M2.375 10.5V5.75c0-.7 0-1.05.136-1.317a1.25 1.25 0 0 1 .547-.547c.267-.136.617-.136 1.317-.136h.66c.076 0 .114 0 .15-.004a.625.625 0 0 0 .452-.28c.02-.03.037-.064.071-.133.07-.137.103-.206.142-.266a1.25 1.25 0 0 1 .905-.559c.071-.008.148-.008.302-.008h1.886c.154 0 .23 0 .302.008.37.042.701.248.905.56.039.06.073.128.142.265.034.07.051.103.07.133a.625.625 0 0 0 .453.28c.036.004.074.004.15.004h.66c.7 0 1.05 0 1.318.136.235.12.426.311.546.547.136.267.136.617.136 1.317v4.75c0 .7 0 1.05-.136 1.318a1.25 1.25 0 0 1-.546.546c-.268.136-.618.136-1.318.136h-7.25c-.7 0-1.05 0-1.317-.136a1.25 1.25 0 0 1-.547-.546c-.136-.268-.136-.618-.136-1.318Z'
    />
  </Svg>
);
export default CameraIcon;
