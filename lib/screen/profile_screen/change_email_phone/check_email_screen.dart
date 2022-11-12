// ignore_for_file: deprecated_member_use, unused_local_variable
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/profile_screen/change_email_phone/check_otp_screen2.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:barg_rider_app/widget/show_aleart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CheckEmailScreen extends StatefulWidget {
  CheckEmailScreen({Key? key}) : super(key: key);

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool statusLoading = false;
  TextEditingController email = TextEditingController();

  check_email() async {
    final response = await http.post(
      Uri.parse('$ipcon/check_email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email.text,
        'status_id': '3',
      }),
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "have email") {
        buildShowAlert(context, "Email alreary in use");
      } else if (data == "dont have email") {
        setState(() {
          statusLoading = true;
        });
        send_otp();
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
        'email': email.text,
      }),
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "send email success") {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return CheckOtpScreen2(
            email: email.text,
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                    BackArrowButton(text: "Checkemail", width2: 0.26),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.04),
                      child: AutoText(
                        width: width * 0.6,
                        text: "Enter New Email",
                        fontSize: 30,
                        color: Colors.white,
                        text_align: TextAlign.center,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    buildEmailBox(),
                    buildButtonContinue()
                  ],
                ),
              ),
            ),
          ),
          LoadingPage(statusLoading: statusLoading)
        ],
      ),
    );
  }

  Widget buildEmailBox() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            width: width * 0.1,
            text: "Email",
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
              controller: email,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(
                    Icons.key,
                    color: Colors.white,
                  ),
                  hintText: "Enter your New Email",
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
          check_email();
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
