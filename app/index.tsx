import { StyleSheet, Text, View, Image, Pressable, Alert } from 'react-native';
import CameraIcon from '../SVG/CameraIcon';
import GalleryIcon from '../SVG/GalleryIcon';
import * as React from 'react';
import Button from './components/Button';
import * as ImagePicker from 'expo-image-picker';
import { useState } from 'react';
import { predict } from '../modules/ml-module';
import { useRouter } from 'expo-router';
import { Header } from '../components/Header';
import { useDetectionResult } from './context/DetectionResultContext';

const Home = () => {
  const [image, setImage] = useState<ImagePicker.ImagePickerAsset | null>(null);
  const router = useRouter();
  const [loading, setLoading] = React.useState(false);
  const { setResult } = useDetectionResult();

  React.useEffect(() => {
    if (!image) return;
    setLoading(true);
    predict(image.uri, { verbose: true })
      .then((value) => {
        setResult(value);
        setLoading(false);
        setImage(null);
        router.push('/board/');
      })
      .catch((error) => {
        console.error(error);
        Alert.alert(
          'Failed to Detect Chessboard',
          'Please try again with a clearer image'
        );
        setLoading(false);
        setImage(null);
      });
  }, [image]);

  const pickImageAsync = async (mode: 'camera' | 'gallery') => {
    let result: ImagePicker.ImagePickerResult;

    if (mode === 'camera') {
      const permission = await ImagePicker.requestCameraPermissionsAsync();
      if (permission.status !== 'granted') {
        alert('Permission to access camera is required!');
        return;
      }
      result = await ImagePicker.launchCameraAsync({
        quality: 1,
      });
    } else {
      result = await ImagePicker.launchImageLibraryAsync({
        quality: 1,
      });
    }

    if (!result.canceled) {
      setImage(result.assets[0]);
    } else {
      setImage(null);
    }
  };

  if (loading) {
    return (
      <View
        style={{
          flex: 1,
          justifyContent: 'center',
          alignItems: 'center',
          backgroundColor: '#161A30',
        }}
      >
        <Text style={{ color: '#fff' }}>Loading...</Text>
      </View>
    );
  }

  return (
    <>
      <Header />
      <View style={{ flex: 1, alignItems: 'center' }}>
        <View style={{ top: 110 }}>
          <Text
            style={{
              color: '#fff',
              fontSize: 24,
              fontWeight: '500',
              width: 318,
              textAlign: 'center',
            }}
          >
            Scan and analyze chess positions
          </Text>
          <Text
            style={{
              color: '#fff',
              textAlign: 'center',
              fontWeight: '400',
              fontSize: 11,
              top: 10,
            }}
          >
            from 2d sources
          </Text>
        </View>
        <View
          style={{
            top: 300,
            width: 224,
            flexDirection: 'column',
            gap: 23,
          }}
        >
          <Button
            style={styles.button}
            onPress={() => {
              pickImageAsync('camera');
            }}
          >
            <CameraIcon />
            <Text
              style={{
                color: '#161A30',
                fontSize: 14,
                fontWeight: '700',
                textAlign: 'center',
              }}
            >
              Take a picture
            </Text>
          </Button>
          <Button onPress={() => pickImageAsync('gallery')}>
            <GalleryIcon />
            <Text
              style={{
                color: '#161A30',
                fontSize: 14,
                fontWeight: '700',
                textAlign: 'center',
              }}
            >
              Image from gallery
            </Text>
          </Button>
        </View>
      </View>
    </>
  );
};

export default Home;

const styles = StyleSheet.create({
  gradient: {
    width: 557.32,
    height: 844.421,
    transform: 'rotate(-52.243deg)',
    borderRadius: 844.421,
    position: 'absolute',
    backgroundColor: '#31304D',
  },

  button: {
    width: '100%',
    backgroundColor: '#fff',
    padding: 10,
    borderRadius: 5,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
