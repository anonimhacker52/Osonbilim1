import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const OsonBilimApp());
}

class OsonBilimApp extends StatelessWidget {
  const OsonBilimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Oson Bilim',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
