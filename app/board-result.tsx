import * as React from 'react';
import { View, Image, Text } from 'react-native';
import { useDetectionResult } from '../context/DetectionResultContext';

const BoardResult = () => {
  const { result } = useDetectionResult();

  return (
    <View
      style={{
        padding: 10,
      }}
    >
      <View
        style={{
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: 10,
            borderWidth: 2,
            borderColor: 'white',
            padding: 5,
          }}
        >
          <Text style={{ color: 'white', fontSize: 20, fontWeight: 'bold' }}>
            Board Result
          </Text>
          <Image
            source={{
              uri: result?.boardResult,
            }}
            style={{
              width: 350,
              height: 350,
              resizeMode: 'contain',
            }}
          />
        </View>
      </View>
    </View>
  );
};

export default BoardResult;
