import * as React from 'react';
import Svg, { SvgProps, Path } from 'react-native-svg';
const MenuIcon = (props: SvgProps) => (
  <Svg width={27} height={18} fill='none' {...props}>
    <Path
      stroke='#B6BBC4'
      strokeLinecap='round'
      strokeLinejoin='round'
      strokeWidth={2.5}
      d='M2 2h23.333M2 9h23.333M2 16h23.333'
    />
  </Svg>
);
export default MenuIcon;
