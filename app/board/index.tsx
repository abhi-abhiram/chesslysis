import React, { useState } from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import EditIcon from '../../SVG/EditIcon';
import StarIcon from '../../SVG/StartIcon';

const BoardView = () => {
  return (
    <View>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Chesslysis</Text>
          <Text style={styles.title2}>Chess position scanner</Text>
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
    </View>
  );
};

export default BoardView;

const Letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

const Board = () => {
  const [board, setBoard] = useState<(string | null)[][]>(
    Array(8).fill(Array(8).fill(null))
  );

  return (
    <View>
      <BoardAplhas />
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'center',
          gap: 2,
        }}
      >
        <BoardNumbers />
        <View
          style={{
            backgroundColor: '#6E614D',
          }}
        >
          {board.map((row, rowIndex) => (
            <View
              key={rowIndex}
              style={{
                flexDirection: 'row',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              {row.map((_, index) => (
                <View
                  key={index}
                  style={{
                    width: 45.5,
                    height: 45.5,
                    backgroundColor:
                      (index + rowIndex) % 2 === 0 ? '#FFF' : '#FFF',
                    opacity: (index + rowIndex) % 2 === 0 ? 1 : 0.28,
                  }}
                ></View>
              ))}
            </View>
          ))}
        </View>
        <BoardNumbers />
      </View>
      <BoardAplhas />
    </View>
  );
};

const BoardAplhas = () => {
  return (
    <View
      style={{
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {Letters.map((letter, index) => (
        <View
          key={index}
          style={{
            width: 45.5,
            justifyContent: 'center',
            alignItems: 'center',
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
            {letter}
          </Text>
        </View>
      ))}
    </View>
  );
};

const BoardNumbers = () => {
  return (
    <View>
      {Letters.map((_, index) => (
        <View
          key={index}
          style={{
            justifyContent: 'center',
            height: 45.5,
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
