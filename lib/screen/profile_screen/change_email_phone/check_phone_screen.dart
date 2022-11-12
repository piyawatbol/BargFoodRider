// ignore_for_file: deprecated_member_use, unused_local_variable
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:barg_rider_app/widget/show_aleart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckPhoneScreen extends StatefulWidget {
  CheckPhoneScreen({Key? key}) : super(key: key);

  @override
  State<CheckPhoneScreen> createState() => _CheckPhoneScreenState();
}

class _CheckPhoneScreenState extends State<CheckPhoneScreen> {
  bool statusLoading = false;
  TextEditingController phone = TextEditingController();
  String? user_id;

  get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
  }

  check_phone() async {
    final response = await http.post(
      Uri.parse('$ipcon/check_phone'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone.text,
        'status_id': '3',
      }),
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "have phone") {
        buildShowAlert(context, "Phone alreary in use");
      } else if (data == "dont have phone") {
        setState(() {
          statusLoading = true;
        });
        change_phone();
      }
    }
  }

  change_phone() async {
    final response = await http.patch(
      Uri.parse('$ipcon/change_phone/$user_id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "phone": phone.text,
      }),
    );
    print(response.body);
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "update phone success") {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    get_user_id();
    super.initState();
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
                    BackArrowButton(text: "ChangePhone", width2: 0.26),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.04),
                      child: AutoText(
                        width: width * 0.6,
                        text: "Enter New Phone",
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
            text: "Phone",
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
              controller: phone,
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
                  hintText: "Enter your New Phone",
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
          check_phone();
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
