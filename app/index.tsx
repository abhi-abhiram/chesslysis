import {
  StyleSheet,
  Text,
  View,
  Pressable,
  Platform,
  StatusBar as StatusBarRN,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native';
import { Header } from '../components/Header';
import CameraIcon from '../SVG/CameraIcon';
import GalleryIcon from '../SVG/GalleryIcon';
import { useRouter } from 'expo-router';
import { hello } from '../modules/ml-module';

const Home = () => {
  const router = useRouter();

  return (
    <View style={{ flex: 1, backgroundColor: 'black' }}>
      <SafeAreaView style={styles.container}>
        <StatusBar style='light' />
        <Header />
        <Hello />
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
              from prints and 2d sources
            </Text>
          </View>
          <View
            style={{ top: 300, width: 224, flexDirection: 'column', gap: 23 }}
          >
            <Pressable
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
            </Pressable>
            <Pressable style={styles.button}>
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
            </Pressable>
          </View>
        </View>
      </SafeAreaView>
    </View>
  );
};

const Hello = () => {
  return (
    <View>
      <Text>{hello()}</Text>
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
