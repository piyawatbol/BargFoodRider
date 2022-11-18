// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_print, use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/login_system/register_screen/confirm_email_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool pass = true;
  bool statusLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController first_name = TextEditingController();
  TextEditingController last_name = TextEditingController();
  TextEditingController user_name = TextEditingController();
  TextEditingController pass_word = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();

  check() {
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gmail.com")
            .hasMatch(email.text);
    if (first_name.text == "") {
      buildShowAlert("Please enter your Firstname");
    } else if (last_name.text == "") {
      buildShowAlert("Please enter your Lastname");
    } else if (user_name.text == "") {
      buildShowAlert("Please enter your Username");
    } else if (email.text == "") {
      buildShowAlert("Please enter your Email");
    } else if (phone.text == "") {
      buildShowAlert("Please enter your Phone");
    } else if (pass_word.text == "") {
      buildShowAlert("Please enter your Password");
    } else if (emailValid == false) {
      buildShowAlert("Please use Gmail");
    } else {
      setState(() {
        statusLoading = true;
      });
      check_duplicate();
    }
  }

  check_duplicate() async {
    final response = await http.post(
      Uri.parse('$ipcon/check_duplicate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_name': user_name.text,
        'email': email.text,
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
      if (data == "duplicate username") {
        buildShowAlert("Username already in use");
      } else if (data == "duplicate email") {
        buildShowAlert("Email already in use");
      } else if (data == "duplicate phone") {
        buildShowAlert("Phone already in use");
      } else if (data == "not duplicate") {
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
          return ConfirmEmailScreen(
            email: email.text,
            first_name: first_name.text,
            last_name: last_name.text,
            pass_word: pass_word.text,
            phone: phone.text,
            user_name: user_name.text,
          );
        }));
      }
    }
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
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      BackArrowButton(text: "Register", width2: 0.18),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        child: AutoText(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          text: 'Register',
                          text_align: TextAlign.center,
                          width: width * 0.38,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.07),
                        child: Column(
                          children: [
                            BulidInputBox("Firstname", first_name, Icons.person,
                                TextInputType.text, 0.16),
                            BulidInputBox("Lastname", last_name, Icons.person,
                                TextInputType.text, 0.16),
                            BulidInputBox("Username", user_name, Icons.person,
                                TextInputType.text, 0.17),
                            BulidInputBox("Email", email, Icons.email,
                                TextInputType.emailAddress, 0.09),
                            BulidInputBox("Phone", phone, Icons.phone,
                                TextInputType.number, 0.11),
                            BulidInputBoxPass(),
                            buildRegisButton()
                          ],
                        ),
                      ),
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

  Widget BulidInputBox(String text, TextEditingController controller,
      IconData? icon, TextInputType? keyboardType, double? width_text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            width: width * width_text!,
            text: text,
            fontSize: 14,
            color: Colors.white,
            text_align: TextAlign.left,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: height * 0.007),
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
              keyboardType: keyboardType,
              obscureText: bool == true ? true : false,
              style: TextStyle(
                color: Colors.white,
              ),
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: Colors.white,
                ),
                hintText: text,
                hintStyle: TextStyle(color: Colors.white54),
                contentPadding: EdgeInsets.only(top: 14),
                border: InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BulidInputBoxPass() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                AutoText(
                    width: width * 0.16,
                    text: "Password",
                    fontSize: 14,
                    color: Colors.white,
                    text_align: TextAlign.left,
                    fontWeight: FontWeight.w600)
              ],
            ),
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
              keyboardType: TextInputType.text,
              obscureText: pass,
              style: TextStyle(
                color: Colors.white,
              ),
              controller: pass_word,
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
                        ),
                      ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.white54),
                contentPadding: EdgeInsets.only(top: 14),
                border: InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRegisButton() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.04),
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
          check();
        },
        child: Center(
          child: AutoText(
            color: Color(0xFF527DAA),
            fontSize: 24,
            text: 'Register',
            text_align: TextAlign.center,
            width: width * 0.18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildShowAlert(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
            child: Text(
          "$text",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
