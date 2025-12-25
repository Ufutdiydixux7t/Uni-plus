import 'package:flutter/material.dart';
import 'features/auth/splash/splash_screen.dart';

class uniplus extends StatelessWidget {
  const uniplus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uni Plus',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        primaryColor: const Color(0xFF3F51B5),
      ),
      home: const SplashScreen(),
    );
  }
}