import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  TouchableOpacity,
} from 'react-native';
import EditIcon from '../SVG/EditIcon';
import StarIcon from '../SVG/StartIcon';
import { Dimensions } from 'react-native';
import Piece from '../components/Piece';
import * as ChessLib from 'chess.js';
import { useDetectionResult } from '../context/DetectionResultContext';
import { ChevronLeft } from 'lucide-react-native';
import { useRouter } from 'expo-router';

const BoardView = () => {
  const router = useRouter();
  return (
    <View>
      <View style={styles.header}>
        <View
          style={{
            flexDirection: 'row',
            gap: 10,
          }}
        >
          <View
            style={{
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <Pressable
              onPress={() => {
                router.push('/');
              }}
              style={({ pressed }) => [
                {
                  width: 24,
                  height: 24,
                  opacity: pressed ? 0.8 : 1,
                },
              ]}
            >
              <ChevronLeft size={24} color='#fff' strokeWidth={2.5} />
            </Pressable>
          </View>
          <View>
            <Text style={styles.title}>Chesslysis</Text>
            <Text style={styles.title2}>Chess position scanner</Text>
          </View>
        </View>
        <View style={styles.groupBtn}>
          <Pressable>
            <EditIcon />
          </Pressable>
          <Pressable>
            <StarIcon />
          </Pressable>
        </View>
      </View>
      <View style={styles.boardContainer}>
        <Board />
      </View>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.push('/board-result')}>
          <Text
            style={{
              color: '#fff',
              fontSize: 16,
              fontWeight: '600',
              padding: 10,
              borderRadius: 5,
            }}
          >
            Show Detection Results
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default BoardView;

const Letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'] as const;

type BoardPositions = (
  | ChessLib.PieceSymbol
  | Uppercase<ChessLib.PieceSymbol>
  | null
)[][];

const Board = () => {
  const deviceWidth = Dimensions.get('window').width;
  const width = getBoardWidth(deviceWidth);
  const { result } = useDetectionResult();
  const [selected, setSelected] = React.useState<[number, number] | null>(null);
  const [game, setGame] = React.useState<ChessLib.Chess | null>(null);
  const [moves, setMoves] = React.useState<ChessLib.Move[]>([]);
  const [lastMove, setLastMove] = React.useState<ChessLib.Move | null>(null);

  const positions = React.useMemo(() => game?.board(), [game, selected, moves]);

  React.useEffect(() => {
    if (!result) return;
    const board = result.positions as BoardPositions;
    const game = new ChessLib.Chess(board_to_fen(board));
    setGame(game);
  }, [result]);

  React.useEffect(() => {
    if (!game) return;
    if (!selected) return;
    const [x, y] = selected;
    const moves = game.moves({
      square: (Letters[x] + (8 - y)) as ChessLib.Square,
      verbose: true,
    });
    setMoves(moves);
  }, [selected]);

  return (
    <View>
      <View
        style={{
          gap: 10,
        }}
      >
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'center',
            gap: 10,
          }}
        >
          <BoardNumbers height={width} />
          <View>
            {positions?.map((row, rowIndex) => (
              <View
                key={rowIndex}
                style={{
                  flexDirection: 'row',
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
              >
                {row.map((square, index) => (
                  <Pressable
                    key={index + rowIndex}
                    style={{
                      width: width,
                      height: width,
                      backgroundColor:
                        (index + rowIndex) % 2 === 0 ? '#E8EDF9' : '#5369A2',
                    }}
                    onPress={() => {
                      if (
                        selected &&
                        selected[0] === index &&
                        selected[1] === rowIndex
                      ) {
                        return;
                      } else if (
                        selected &&
                        moves.find(
                          (move) => move.to === Letters[index] + (8 - rowIndex)
                        )
                      ) {
                        setLastMove(
                          game!.move({
                            from: Letters[selected[0]] + (8 - selected[1]),
                            to: Letters[index] + (8 - rowIndex),
                          })
                        );
                        setSelected(null);
                        setMoves([]);
                      } else if (square) {
                        setSelected([index, rowIndex]);
                      }
                    }}
                  >
                    <View
                      style={{
                        width: '100%',
                        height: '100%',
                        justifyContent: 'center',
                        alignItems: 'center',
                        backgroundColor: '#7B61FF',
                        opacity:
                          selected &&
                          square !== null &&
                          selected[0] === index &&
                          selected[1] === rowIndex
                            ? 0.5
                            : 0,
                        top: 0,
                        left: 0,
                        position: 'absolute',
                      }}
                    ></View>
                    {moves.find(
                      (move) => move.to === Letters[index] + (8 - rowIndex)
                    ) && (
                      <>
                        <View
                          style={{
                            width: '100%',
                            height: '100%',
                            justifyContent: 'center',
                            alignItems: 'center',
                            opacity: square ? 1 : 0,
                            top: 0,
                            left: 0,
                            position: 'absolute',
                            backgroundColor: '#7B61FF',
                          }}
                        >
                          <View
                            style={{
                              width: '99%',
                              height: '99%',
                              backgroundColor:
                                (index + rowIndex) % 2 === 0
                                  ? '#E8EDF9'
                                  : '#5369A2',
                              borderRadius: 100,
                            }}
                          ></View>
                        </View>
                        {!square && (
                          <View
                            style={{
                              width: '100%',
                              height: '100%',
                              top: 0,
                              left: 0,
                              position: 'absolute',
                              alignItems: 'center',
                              justifyContent: 'center',
                            }}
                          >
                            <View
                              style={{
                                width: 24,
                                height: 24,
                                borderRadius: 12,
                                backgroundColor: '#7B61FF',
                              }}
                            ></View>
                          </View>
                        )}
                      </>
                    )}
                    {square && (
                      <Piece
                        name={
                          (square?.color === 'w'
                            ? square.type.toUpperCase()
                            : square.type) as ChessLib.PieceSymbol
                        }
                        width={width}
                      />
                    )}
                  </Pressable>
                ))}
              </View>
            ))}
          </View>
        </View>
        <BoardAplhas width={width} />
      </View>
    </View>
  );
};

const BoardAplhas = ({ width }: { width: number }) => {
  return (
    <View
      style={{
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginLeft: 15,
      }}
    >
      {Letters.map((letter, index) => (
        <View
          key={index}
          style={{
            width: width,
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          <Text
            style={{
              color: '#E6E6E6',
              fontSize: 10,
              fontWeight: '400',
            }}
          >
            {letter}
          </Text>
        </View>
      ))}
    </View>
  );
};

const BoardNumbers = ({ height }: { height: number }) => {
  return (
    <View>
      {Letters.map((_, index) => (
        <View
          key={index}
          style={{
            justifyContent: 'center',
            height,
          }}
        >
          <Text
            style={{
              color: '#E6E6E6',
              fontSize: 10,
              fontWeight: '400',
              height: 12.4,
            }}
          >
            {8 - index}
          </Text>
        </View>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  header: {
    paddingTop: 10,
    paddingBottom: 10,
    backgroundColor: '#161A30',
    paddingLeft: 20,
    paddingRight: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    zIndex: 1,
  },
  title: {
    color: '#fff',
    fontSize: 20,
    fontWeight: '800',
  },
  title2: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '400',
  },
  groupBtn: {
    flexDirection: 'row',
    gap: 17,
  },
  boardContainer: {
    paddingTop: 20,
    paddingBottom: 20,
  },
});

function getBoardWidth(deviceWidth: number) {
  if (deviceWidth < 400) {
    return 45.5;
  }
  if (deviceWidth < 600) {
    return 50;
  }
  if (deviceWidth < 800) {
    return 60;
  }
  if (deviceWidth < 1000) {
    return 70;
  }
  return 80;
}

function board_to_fen(board: BoardPositions) {
  let result = '';

  for (let y = 0; y < board.length; y++) {
    let empty = 0;
    for (let x = 0; x < board[y].length; x++) {
      let c = board[y][x]?.[0]; // Fixed
      if (c) {
        if (empty > 0) {
          result += empty.toString();
          empty = 0;
        }
        result += c;
      } else {
        empty += 1;
      }
    }
    if (empty > 0) {
      // Fixed
      result += empty.toString();
    }
    if (y < board.length - 1) {
      // Added to eliminate last '/'
      result += '/';
    }
  }
  result += ' w KQkq - 0 1';
  return result;
}
