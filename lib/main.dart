// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unnecessary_new, depend_on_referenced_packages
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart'; // อย่าลืมตัวนี้
import 'package:barg_rider_app/start_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barg Food Driver',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: SizedBox(
            width: 1000,
            height: 1000,
            child: Image.asset("assets/images/logo.png")),
      ),
      nextScreen: StartScreen(),
      splashIconSize: 200,
      backgroundColor: Color(0xff85BFF4),
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.topToBottom,
    );
  }
}
