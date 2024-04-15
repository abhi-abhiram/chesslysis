import { Pressable, StyleSheet } from 'react-native';

export default function Button({
  children,
  onPress,
}: {
  children: React.ReactNode;
  style?: any;
  onPress?: () => void;
}) {
  return (
    <Pressable onPress={onPress} style={buttonStyles.button}>
      {children}
    </Pressable>
  );
}

const buttonStyles = StyleSheet.create({
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
