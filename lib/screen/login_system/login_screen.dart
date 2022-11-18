// ignore_for_file: deprecated_member_use, unused_local_variable, unnecessary_null_comparison
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/home_screen.dart';
import 'package:barg_rider_app/screen/login_system/forget_screen/forget_password.dart';
import 'package:barg_rider_app/screen/login_system/register_screen/register_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool pass = true;
  TextEditingController user_name = TextEditingController();
  TextEditingController pass_word = TextEditingController();
  bool statusLoading = false;
  List userList = [];
  List storeList = [];
  bool userError = false;
  bool passError = false;

  Future accept_email() async {
    final response = await http.post(
      Uri.parse('$ipcon/email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': userList[0]['email'],
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
  }

  Future login() async {
    final response = await http.post(
      Uri.parse('$ipcon/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_name': user_name.text,
        'pass_word': pass_word.text,
        'status_id': '3'
      }),
    );

    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "dont have user") {
      buildShowAlert("Username or Password Incorrect");
    } else {
      setState(() {
        userList = data;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('user_id', userList[0]['user_id'].toString());
      print("login user_id : ${preferences.getString('user_id')}");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }), (route) => false);
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
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: height * 0.08),
                          child: AutoText(
                            text: "Login",
                            width: width * 0.35,
                            fontSize: 50,
                            color: Colors.white,
                            text_align: TextAlign.center,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        buildInputBoxUser(),
                        SizedBox(height: height * 0.02),
                        buildInputBoxPass(),
                        buildForgetpass(),
                        buildLoingButton(),
                        buildRegister()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            LoadingPage(statusLoading: statusLoading),
          ],
        ),
      ),
    );
  }

  Widget buildInputBoxUser() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(
          width: width * 0.18,
          text: "Username",
          fontSize: 16,
          color: Colors.white,
          text_align: TextAlign.left,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(
          height: height * 0.004,
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
            controller: user_name,
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
                hintText: "Enter your Username",
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                enabledBorder: userError == true
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.5),
                        borderRadius: BorderRadius.circular(15),
                      )
                    : null,
                focusedBorder: userError == true
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.5),
                        borderRadius: BorderRadius.circular(15),
                      )
                    : null),
          ),
        ),
        userError == true
            ? Text(
                "please enter your username",
                style: TextStyle(color: Colors.red),
              )
            : Container()
      ],
    );
  }

  Widget buildInputBoxPass() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(
          width: width * 0.17,
          text: "Password",
          fontSize: 16,
          color: Colors.white,
          text_align: TextAlign.left,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(
          height: height * 0.004,
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
            controller: pass_word,
            obscureText: pass,
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
              hintText: "Enter your Password",
              hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
              enabledBorder: passError == true
                  ? OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    )
                  : null,
              focusedBorder: passError == true
                  ? OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    )
                  : null,
            ),
          ),
        ),
        passError == true
            ? Text(
                "please enter your password",
                style: TextStyle(color: Colors.red),
              )
            : Container()
      ],
    );
  }

  Widget buildForgetpass() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Row(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ForgetPassword();
                }));
              },
              child: AutoText(
                color: Colors.white,
                fontSize: 12,
                text: 'Forget Password',
                text_align: TextAlign.left,
                width: width * 0.25,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget buildLoingButton() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 50),
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
          if (user_name.text == "") {
            setState(() {
              userError = true;
            });
          } else {
            setState(() {
              userError = false;
            });
          }
          if (pass_word.text == "") {
            setState(() {
              passError = true;
            });
          } else {
            setState(() {
              passError = false;
            });
          }
          if (user_name.text != "" && pass_word.text != "") {
            setState(() {
              statusLoading = true;
            });
            login();
          }
        },
        child: Center(
          child: AutoText(
            color: Color(0xFF527DAA),
            fontSize: 24,
            text: 'Login',
            text_align: TextAlign.center,
            width: width * 0.18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildRegister() {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoText(
          width: width * 0.33,
          text: "Don't have Accout?",
          fontSize: 14,
          color: Colors.white,
          text_align: TextAlign.right,
          fontWeight: null,
        ),
        SizedBox(
          width: 1,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return RegisterScreen();
                },
              ),
            );
          },
          child: AutoText(
            color: Colors.white,
            fontSize: 14,
            text: 'Register',
            text_align: TextAlign.left,
            width: width * 0.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
                if (text == "Email not accept") {
                  setState(() {
                    statusLoading = true;
                  });
                  accept_email();
                }
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
