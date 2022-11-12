// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/profile_screen/change_email_phone/check_email_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:barg_rider_app/widget/show_aleart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckPassEmailScreen extends StatefulWidget {
  CheckPassEmailScreen({Key? key}) : super(key: key);

  @override
  State<CheckPassEmailScreen> createState() => _CheckPassEmailScreenState();
}

class _CheckPassEmailScreenState extends State<CheckPassEmailScreen> {
  bool pass = true;
  bool statusLoading = false;
  TextEditingController pass_word = TextEditingController();

  check_password() async {
    String? user_id;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response = await http.post(
      Uri.parse('$ipcon/check_password/$user_id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"pass_word": pass_word.text}),
    );
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      var data = json.decode(response.body);
      if (data == "correct") {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return CheckEmailScreen();
        }));
      } else if (data == "not correct") {
        buildShowAlert(context, "Password Incorrect");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF73AEF5),
                    Color(0xFF61A4F1),
                    Color(0xFF478De0),
                    Color(0xFF398AE5)
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      BackArrowButton(text: "Check Password", width2: 0.36),
                      Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.04),
                            child: AutoText(
                              width: width * 0.45,
                              text: "Enter Password",
                              fontSize: 24,
                              color: Colors.white,
                              text_align: TextAlign.center,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          buildBoxPass(),
                          buildButtonContinue()
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            LoadingPage(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildBoxPass() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            width: width * 0.15,
            text: "Password",
            fontSize: 14,
            color: Colors.white,
            text_align: TextAlign.left,
            fontWeight: null,
          ),
          SizedBox(height: height * 0.004),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF6CA8F1),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              obscureText: pass,
              controller: pass_word,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  suffixIcon: pass == true
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              pass = !pass;
                            });
                          },
                          icon: Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                          ))
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              pass = !pass;
                            });
                          },
                          icon: Icon(
                            Icons.visibility,
                            color: Colors.white,
                          )),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(
                    Icons.key,
                    color: Colors.white,
                  ),
                  hintText: "Enter your Password",
                  hintStyle: TextStyle(color: Colors.white54)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtonContinue() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: height * 0.07, horizontal: width * 0.07),
      width: double.infinity,
      height: height * 0.055,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          setState(() {
            statusLoading = true;
          });
          check_password();
        },
        child: Center(
          child: AutoText(
            color: Color(0xFF527DAA),
            fontSize: 24,
            text: 'Continue',
            text_align: TextAlign.center,
            width: width * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
