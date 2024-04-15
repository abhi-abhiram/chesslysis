import FontAwesome from '@expo/vector-icons/FontAwesome';
import { useFonts } from 'expo-font';
import { SplashScreen } from 'expo-router';
import { useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  View,
  Platform,
  StatusBar as StatusBarRN,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { DetectionResultProvider } from '../context/DetectionResultContext';
import { Stack } from 'expo-router';

export {
  // Catch any errors thrown by the Layout component.
  ErrorBoundary,
} from 'expo-router';

export const unstable_settings = {
  // Ensure that reloading on `/modal` keeps a back button present.
  initialRouteName: '(tabs)',
};

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [loaded, error] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
    ...FontAwesome.font,
  });

  // Expo Router uses Error Boundaries to catch errors in the navigation tree.
  useEffect(() => {
    if (error) throw error;
  }, [error]);

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync();
    }
  }, [loaded]);

  if (!loaded) {
    return null;
  }

  return <RootLayoutNav />;
}

function RootLayoutNav() {
  return (
    <View style={{ flex: 1 }}>
      <SafeAreaView style={styles.container}>
        <StatusBar style='light' />
        <DetectionResultProvider>
          <Stack
            screenOptions={{
              contentStyle: {
                backgroundColor: '#161A30',
                flex: 1,
              },
            }}
          >
            <Stack.Screen
              name='index'
              options={{
                headerShown: false,
                headerTitle: 'Home',
              }}
            />
            <Stack.Screen
              name='board'
              options={{
                headerShown: false,
              }}
            />
            <Stack.Screen
              name='board-result'
              options={{
                title: 'Detection Result',
                presentation: 'modal',
                headerTitleStyle: {
                  color: 'white',
                },
                headerStyle: {
                  backgroundColor: '#161A30',
                },
              }}
            />
          </Stack>
        </DetectionResultProvider>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#161A30',
    paddingTop: Platform.OS === 'android' ? StatusBarRN.currentHeight : 0,
  },
});
