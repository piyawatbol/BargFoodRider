// ignore_for_file: deprecated_member_use, must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/login_system/forget_screen/reset_screen.dart';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckOtpScreen extends StatefulWidget {
  String email;
  CheckOtpScreen({required this.email});

  @override
  State<CheckOtpScreen> createState() => _CheckOtpScreenState();
}

class _CheckOtpScreenState extends State<CheckOtpScreen> {
  bool statusLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController num1 = TextEditingController();
  TextEditingController num2 = TextEditingController();
  TextEditingController num3 = TextEditingController();
  TextEditingController num4 = TextEditingController();
  TextEditingController num5 = TextEditingController();
  TextEditingController num6 = TextEditingController();

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

  checkOtp(sum) async {
    final response = await http.post(
      Uri.parse('$ipcon/checkOtp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
        'checkOtp': sum.toString(),
      }),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data == "Correct") {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ResetScreen(
            email: widget.email,
          );
        }));
      } else if (data == "Not Correct") {
        showDialog(
            context: context, builder: (context) => BuildShow("Otp Incorrect"));
      }
    }
  }

  sendOtp() async {
    final response = await http.post(
      Uri.parse('$ipcon/email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "send email success") {
        startTimer();
        showDialog(
            context: context,
            builder: (context) => BuildShow("Send email again"));
      } else if (data == "not have email") {
        showDialog(
            context: context,
            builder: (context) => BuildShow("Email not found"));
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 30,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "${widget.email}",
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BuildBoxOtp(num1),
                            BuildBoxOtp(num2),
                            BuildBoxOtp(num3),
                            BuildBoxOtp(num4),
                            BuildBoxOtp(num5),
                            BuildBoxOtp(num6),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        _Counter == 0
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    statusLoading = true;
                                  });
                                  sendOtp();
                                },
                                child: Text(
                                  "send again ",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ))
                            : Text("Resend in $_Counter seconds",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.11,
                          child: RaisedButton(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            onPressed: () {
                              final sum = num1.text +
                                  num2.text +
                                  num3.text +
                                  num4.text +
                                  num5.text +
                                  num6.text;
                              print(sum);
                              checkOtp(sum);
                            },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Color(0xFF527DAA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: statusLoading == true ? true : false,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  statusLoading = false;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: Colors.white38),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildBoxOtp(TextEditingController? controller) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.12,
      width: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF6CA8F1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.length == 0) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
      ),
    );
  }

  Widget BuildShow(String? text) {
    return SimpleDialog(
      title: Center(
          child: Text("$text",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
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
            child: Text('Ok'),
          ),
        )
      ],
    );
  }
}
