import { Camera, CameraType } from 'expo-camera';
import { useState } from 'react';
import {
  Button,
  Pressable,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import CircleCrossIcon from '../SVG/CircleCrossIcon';
import { useRouter } from 'expo-router';

export default function App() {
  const [type, setType] = useState(CameraType.back);
  const [permission, requestPermission] = Camera.useCameraPermissions();
  const router = useRouter();

  if (!permission) {
    // Camera permissions are still loading
    return <View />;
  }

  if (!permission.granted) {
    // Camera permissions are not granted yet
    return (
      <View style={styles.container}>
        <Text style={{ textAlign: 'center' }}>
          We need your permission to show the camera
        </Text>
        <Button onPress={requestPermission} title='grant permission' />
      </View>
    );
  }

  function toggleCameraType() {
    setType((current) =>
      current === CameraType.back ? CameraType.front : CameraType.back
    );
  }

  return (
    <View style={styles.container}>
      <Camera style={styles.camera} type={type}>
        <View style={styles.container2}>
          <View style={{ position: 'absolute', top: 58, left: 26 }}>
            <Pressable
              onPress={() => {
                router.push('/');
              }}
            >
              <CircleCrossIcon />
            </Pressable>
          </View>
          <View style={styles.buttonContainer}>
            <TouchableOpacity
              style={styles.camerabtn}
              onPress={toggleCameraType}
            ></TouchableOpacity>
          </View>
        </View>
      </Camera>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  camera: {
    flex: 1,
  },
  container2: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: 'transparent',
  },
  buttonContainer: {
    width: '100%',
    flexDirection: 'row',
    alignSelf: 'flex-end',
    alignItems: 'center',
    marginBottom: 64,
    justifyContent: 'center',
  },
  button: {},
  camerabtn: {
    width: 80,
    height: 80,
    borderRadius: 10000,
    backgroundColor: '#fff',
    borderWidth: 5,
  },
  text: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
});
