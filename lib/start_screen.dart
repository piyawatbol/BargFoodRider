// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_constructors_in_immutables, use_build_context_synchronously, non_constant_identifier_names
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/home_screen.dart';
import 'package:barg_rider_app/screen/login_system/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String id = "";
  check_connect() async {
    Timer.periodic(new Duration(seconds: 1), (timer) async {
      print("loading ...");
      final response = await http.get(Uri.parse("$ipcon/"));
      var data = json.decode(response.body);
      print(data);
      if (response.statusCode == 200) {
        print("connected");
        timer.cancel();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        if (preferences.getString("user_id") == null) {
          preferences.setString("user_id", "");
        } else {
          setState(() {
            id = preferences.getString('user_id')!;
          });
        }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return id == "" ? LoginScreen() : HomeScreen();
        }));
      }
    });
  }

  @override
  void initState() {
    check_connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.white,
            ],
          ),
        ),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/logo.png",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: SpinKitThreeBounce(
              color: Colors.blue,
              size: 30,
            ),
          )
        ],
      ),
      ),
    );
  }
}
