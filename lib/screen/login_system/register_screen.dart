// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_print, use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'package:barg_rider_app/screen/login_system/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
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
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();

  Widget BulidInputBox(String text, TextEditingController controller,
      IconData? icon, TextInputType? keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Text(
                  "$text",
                  style: TextStyle(color: Colors.white),
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Text(
                  "Password",
                  style: TextStyle(color: Colors.white),
                ),
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
              keyboardType: TextInputType.name,
              obscureText: pass,
              style: TextStyle(
                color: Colors.white,
              ),
              controller: password,
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

  Future register() async {
    final response = await http.post(
      Uri.parse('$ipcon/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'first_name': firstname.text,
        'last_name': lastname.text,
        'user_name': username.text,
        'password': password.text,
        'email': email.text,
        'user_image': '',
        'status_id': '2',
        'address_id': '0'
      }),
    );

    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "firstname null") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Please enter your Firstname"));
    } else if (data == "lastname null") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Please enter your Lastname"));
    } else if (data == "username null") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Please enter your Username"));
    } else if (data == "email null") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Please enter your Email"));
    } else if (data == "password null") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Please enter your Password"));
    } else if (data == "password 6") {
      showDialog(
          context: context,
          builder: (context) =>
              BuildShow("Please enter a password of more than 6 characters"));
    }
    if (data == "duplicate username") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("Username is already in use"));
    } else if (data == "duplicate email") {
      showDialog(
          context: context,
          builder: (context) => BuildShow("This Email is already in use"));
    } else if (data == "Resgister Success") {
      showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Center(child: Text("Register Success Fully")),
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return LoginScreen();
                        }));
                      },
                      child: Text('ตกลง'),
                    ),
                  )
                ],
              ));
    }
  }

  Show(String? text, Function page) {
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Center(child: Text(text.toString())),
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
                      () => page;
                    },
                    child: Text('Ok'),
                  ),
                )
              ],
            ));
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
              child: SingleChildScrollView(
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
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Text(
                          "Resgister",
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              BulidInputBox("Firstname", firstname,
                                  Icons.person, TextInputType.name),
                              BulidInputBox("Lastname", lastname, Icons.person,
                                  TextInputType.name),
                              BulidInputBox("Username", username, Icons.person,
                                  TextInputType.name),
                              BulidInputBox("Email", email, Icons.email,
                                  TextInputType.emailAddress),
                              BulidInputBoxPass(),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 25),
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.11,
                                child: RaisedButton(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  onPressed: () {
                                    register();
                                  },
                                  child: Text(
                                    "Register",
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
                      ),
                    ],
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
}
