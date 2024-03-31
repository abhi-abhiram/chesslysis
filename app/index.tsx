import {
  StyleSheet,
  Text,
  View,
  Platform,
  StatusBar as StatusBarRN,
  Image,
  Pressable,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native';
import { Header } from '../components/Header';
import CameraIcon from '../SVG/CameraIcon';
import GalleryIcon from '../SVG/GalleryIcon';
import { useRouter } from 'expo-router';
import * as React from 'react';
import Button from './components/Button';
import * as ImagePicker from 'expo-image-picker';
import { useState } from 'react';
import { predict } from '../modules/ml-module';

const Home = () => {
  const router = useRouter();
  const [image, setImage] = useState<ImagePicker.ImagePickerAsset | null>(null);
  const [result, setResult] = useState<string | null>(null);

  React.useEffect(() => {
    if (!image) return;
    predict(image.uri)
      .then((value) => {
        console.log(value);
        setResult(value);
      })
      .catch((error) => console.log(error));
  }, [image]);

  const pickImageAsync = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      quality: 1,
    });

    if (!result.canceled) {
      setImage(result.assets[0]);
    } else {
      setImage(null);
    }
  };

  return (
    <View style={{ flex: 1, backgroundColor: 'black' }}>
      <SafeAreaView style={styles.container}>
        <StatusBar style='light' />
        <Header />
        <View style={{ flex: 1, alignItems: 'center' }}>
          {!result ? (
            <>
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
                  from prints and 2d sources
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
                    router.push('/camera');
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
                <Button onPress={pickImageAsync}>
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
            </>
          ) : (
            <>
              <Image
                source={{
                  uri: result,
                }}
                style={{
                  marginTop: 50,
                  width: 350,
                  height: 350,
                  resizeMode: 'contain',
                }}
              />
              <Pressable
                style={{
                  position: 'absolute',
                  bottom: 20,
                  width: 100,
                  height: 100,
                  backgroundColor: '#fff',
                  borderRadius: 50,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
                onPress={() => {
                  setImage(null);
                  setResult(null);
                }}
              >
                <Text>Clear</Text>
              </Pressable>
            </>
          )}
        </View>
      </SafeAreaView>
    </View>
  );
};

export default Home;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#161A30',
    paddingTop: Platform.OS === 'android' ? StatusBarRN.currentHeight : 0,
  },
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
