import { PieceSymbol } from 'chess.js';
import * as React from 'react';
import {
  RookB,
  RookW,
  BishopB,
  BishopW,
  KingB,
  KingW,
  KnightB,
  KnightW,
  PawnB,
  PawnW,
  QueenB,
  QueenW,
} from '../assets/images';
import { Text } from 'react-native';

type PieceProps = {
  name: PieceSymbol | Uppercase<PieceSymbol> | null;
  width?: number;
  height?: number;
};

const Piece = ({ name, width }: PieceProps) => {
  switch (name) {
    case 'r':
      return <RookB width={width} height={width} />;
    case 'R':
      return <RookW width={width} height={width} />;
    case 'b':
      return <BishopB width={width} height={width} />;
    case 'B':
      return <BishopW width={width} height={width} />;
    case 'k':
      return <KingB width={width} height={width} />;
    case 'K':
      return <KingW width={width} height={width} />;
    case 'n':
      return <KnightB width={width} height={width} />;
    case 'N':
      return <KnightW width={width} height={width} />;
    case 'p':
      return <PawnB width={width} height={width} />;
    case 'P':
      return <PawnW width={width} height={width} />;
    case 'q':
      return <QueenB width={width} height={width} />;
    case 'Q':
      return <QueenW width={width} height={width} />;

    default:
      break;
  }

  return <Text>{name}</Text>;
};

export default Piece;
