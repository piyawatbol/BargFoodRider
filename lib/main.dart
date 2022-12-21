// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unnecessary_new, depend_on_referenced_packages
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:barg_rider_app/screen/splash_screen.dart';
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
