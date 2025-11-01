import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';


void main() {
  runApp(const MahmoodMasjidApp());
}

class MahmoodMasjidApp extends StatelessWidget {
  const MahmoodMasjidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahmood Masjid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'NotoNastaliqUrdu', 
      ),
      home: const SplashScreen(),
    );
  }
}

