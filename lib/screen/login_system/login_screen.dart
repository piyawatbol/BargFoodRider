// ignore_for_file: deprecated_member_use, unused_local_variable
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/home_screen.dart';
import 'package:barg_rider_app/screen/login_system/forget_screen/forget_password.dart';
import 'package:barg_rider_app/screen/login_system/register_screen/confirm_email_screen.dart';
import 'package:barg_rider_app/screen/login_system/register_screen/register_screen.dart';
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
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool statusLoading = false;
  final formKey = GlobalKey<FormState>();
  List userList = [];

  accept_email() async {
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
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return ConfrimEmailScreen(email: userList[0]['email']);
      }));
    }
  }

  login() async {
    final response = await http.post(
      Uri.parse('$ipcon/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_name': username.text,
        'password': password.text,
        'status_id': '3'
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        statusLoading = false;
      });
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        userList = data;
      });
      if (userList[0]['accept_status'] == "0") {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Center(
                child: Text(
              "Email Unaccept",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
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
                  onPressed: () async {
                    setState(() {
                      statusLoading = true;
                    });
                    Navigator.pop(context);
                    accept_email();
                  },
                  child: Text('Go to accept email'),
                ),
              )
            ],
          ),
        );
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('user_id', userList[0]['user_id'].toString());
        print("login user_id : ${preferences.getString('user_id')}");

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }));
      }
    } else if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Center(
              child: Text(
            "Username or Password incorrect",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )),
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
                child: Text('ok'),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
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
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            BuildInputBoxUser(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.018,
                            ),
                            BuildInputBoxPass(),
                            Container(
                              alignment: Alignment.topRight,
                              child: FlatButton(
                                  padding: EdgeInsets.only(right: 0),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return ForgetPassword();
                                    }));
                                  },
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25),
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.11,
                              child: RaisedButton(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                onPressed: () {
                                  final isValid =
                                      formKey.currentState!.validate();
                                  if (isValid) {
                                    setState(() {
                                      statusLoading = true;
                                    });
                                    login();
                                  }
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Color(0xFF527DAA),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an Account?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return RegisterScreen();
                                    }));
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
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
      ),
    );
  }

  Widget BuildInputBoxPass() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
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
            controller: password,
            obscureText: pass,
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
                hintText: "Enter your Password",
                hintStyle: TextStyle(color: Colors.white54)),
          ),
        )
      ],
    );
  }

  Widget BuildInputBoxUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username",
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
            controller: username,
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
                hintText: "Enter your Username",
                hintStyle: TextStyle(color: Colors.white54)),
          ),
        )
      ],
    );
  }
}
