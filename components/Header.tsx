import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export const Header = () => {
  return (
    <View style={styles.header}>
      <View>
        <Text style={styles.title}>Chesslysis</Text>
        <Text style={styles.title2}>Chess position scanner</Text>
      </View>
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
});
