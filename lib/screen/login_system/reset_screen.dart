// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, deprecated_member_use, must_be_immutable
import 'dart:convert';
import 'package:barg_rider_app/screen/login_system/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
import 'package:flutter/material.dart';

class ResetScreen extends StatefulWidget {
  String? email;
  ResetScreen({required this.email});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  bool statusLoading = false;
  TextEditingController pass1 = TextEditingController();
  TextEditingController pass2 = TextEditingController();

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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return LoginScreen();
              }));
            },
            child: Text('Ok'),
          ),
        )
      ],
    );
  }

  Widget BuildPassBox(String? text, TextEditingController? controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$text",
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
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
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                hintText: "$text",
                hintStyle: TextStyle(color: Colors.white54)),
          ),
        )
      ],
    );
  }

  reset_pass() async {
    final response = await http.post(
      Uri.parse('$ipcon/reset'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email.toString(),
        'Newpassword': pass1.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      var data = json.decode(response.body);
      if (data == "reset success") {
        showDialog(
            context: context,
            builder: (context) => BuildShow("Reset Password Success Fully"));
      }
    }
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: Column(
                      children: [
                        BuildPassBox("Password", pass1),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        BuildPassBox("Confirm Password", pass2),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.11,
                          child: RaisedButton(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            onPressed: () {
                              if (pass1.text != pass2.text) {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        BuildShow("Passwords do not match"));
                              } else {
                                setState(() {
                                  statusLoading = true;
                                });
                                reset_pass();
                              }
                            },
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                  color: Color(0xFF527DAA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
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
}
