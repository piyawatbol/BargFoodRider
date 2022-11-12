// ignore_for_file: deprecated_member_use, must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/login_system/forget_screen/reset_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CheckOtpScreen extends StatefulWidget {
  String email;
  CheckOtpScreen({required this.email});

  @override
  State<CheckOtpScreen> createState() => _CheckOtpScreenState();
}

class _CheckOtpScreenState extends State<CheckOtpScreen> {
  bool statusLoading = false;
  TextEditingController otp = TextEditingController();

  int _Counter = 60;
  late Timer _timer;

  void startTimer() {
    _Counter = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_Counter > 0) {
        if (this.mounted) {
          setState(() {
            _Counter--;
          });
        }
      } else {
        _timer.cancel();
      }
      //   print(_Counter);
    });
  }

  check_otp(sum) async {
    final response = await http.post(
      Uri.parse('$ipcon/check_otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
        'otp': otp.text,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      var data = json.decode(response.body);
      print(data);
      if (data == "correct") {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ResetScreen(
            email: widget.email,
          );
        }));
      } else if (data == "not correct") {
        buildShowAlert("Otp Incorrect");
      }
    }
  }

  send_otp() async {
    final response = await http.post(
      Uri.parse('$ipcon/send_otp_email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "send email success") {
        buildShowAlert("Send email Again");
        startTimer();
      }
    }
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                      BackArrowButton(text: "Otp", width2: 0.1),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.05),
                        child: AutoText(
                          width: width * 0.7,
                          text: "${widget.email}",
                          fontSize: 24,
                          color: Colors.white,
                          text_align: TextAlign.center,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildInputBoxOtp(),
                      buildSendAgain(),
                      buildButtonContinnue(),
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

  Widget buildInputBoxOtp() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            width: width * 0.07,
            text: "Otp",
            fontSize: 14,
            color: Colors.white,
            text_align: TextAlign.left,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(
            height: height * 0.01,
          ),
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
            child: TextField(
              keyboardType: TextInputType.number,
              controller: otp,
              obscureText: false,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                hintMaxLines: 1,
                hintText: "Enter your otp",
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSendAgain() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _Counter == 0
        ? TextButton(
            onPressed: () {
              setState(() {
                statusLoading = true;
              });
              send_otp();
            },
            child: AutoText(
              color: Colors.white,
              fontSize: 14,
              fontWeight: null,
              text: 'send again',
              text_align: TextAlign.center,
              width: width * 0.18,
            ))
        : Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            child: AutoText(
              width: width * 0.31,
              text: "Resend in $_Counter seconds",
              fontSize: 14,
              color: Colors.white,
              text_align: TextAlign.center,
              fontWeight: null,
            ),
          );
  }

  Widget buildButtonContinnue() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: height * 0.04, horizontal: width * 0.07),
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
          check_otp(otp.text);
        },
        child: Center(
          child: AutoText(
            color: Color(0xFF527DAA),
            fontSize: 24,
            text: 'Continnue',
            text_align: TextAlign.center,
            width: width * 0.31,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildShowAlert(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
            child: Text(
          "$text",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.1, vertical: height * 0.01),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.white,
                primary: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: AutoText(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                text: 'Ok',
                text_align: TextAlign.center,
                width: width * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
