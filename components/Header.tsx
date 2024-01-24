import React from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import MenuIcon from '../SVG/MenuIcon';

export const Header = () => {
  return (
    <View style={styles.header}>
      <View>
        <Text style={styles.title}>Chessvision.ai</Text>
        <Text style={styles.title2}>Chess position scanner</Text>
      </View>
      <MenuIcon />
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
