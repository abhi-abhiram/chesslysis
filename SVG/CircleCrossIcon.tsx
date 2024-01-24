import * as React from 'react';
import Svg, { SvgProps, Circle, Path } from 'react-native-svg';
const CircleCrossIcon = (props: SvgProps) => (
  <Svg width={24} height={24} fill='none' {...props}>
    <Circle
      cx={12}
      cy={12}
      r={10}
      fill='#F0ECE5'
      stroke='#31304D'
      strokeWidth={1.5}
    />
    <Path
      stroke='#31304D'
      strokeLinecap='round'
      strokeWidth={1.5}
      d='m14.5 9.5-5 5m0-5 5 5'
    />
  </Svg>
);
export default CircleCrossIcon;
