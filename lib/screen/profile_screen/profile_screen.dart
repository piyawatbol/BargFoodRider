// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/login_system/login_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/edit_proflile_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/history_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/received_order_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/report_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/show_big_img.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List userList = [];

  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return LoginScreen();
    }));
  }

  get_user() async {
    String? user_id;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response = await http.get(Uri.parse("$ipcon/get_user/$user_id"));
    var data = json.decode(response.body);
    setState(() {
      userList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
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
                BackArrowButton(text: 'Profile', width2: 0.15),
                SizedBox(height: height * 0.02),
                buildProfile(),
                buildName(),
                buildButtonEdit(),
                SizedBox(height: height * 0.05),
                buildReceived_order(),
                buildHistory_order(),
                buildButtonReport(),
                buildButtonLogout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfile() {
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: get_user(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return userList.isEmpty
            ? buildLoadingProfile()
            : userList[0]['user_image'] == ""
                ? CircleAvatar(
                    radius: width * 0.18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: width * 0.16,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ShowBigImg(img: userList[0]['user_image']);
                          },
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: width * 0.18,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: width * 0.16,
                        backgroundImage: NetworkImage(
                          "$path_img/users/${userList[0]['user_image']}",
                        ),
                      ),
                    ),
                  );
      },
    );
  }

  Widget buildName() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: Column(
        children: [
          userList.isEmpty
              ? buildLoadingName(0.45)
              : AutoText(
                  width: width * 0.65,
                  text:
                      "${userList[0]['first_name']} ${userList[0]['last_name']}",
                  fontSize: 20,
                  color: Colors.white,
                  text_align: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
          userList.isEmpty
              ? buildLoadingName(0.3)
              : AutoText(
                  width: width * 0.65,
                  text: "${userList[0]['email']}",
                  fontSize: 12,
                  color: Colors.grey.shade300,
                  text_align: TextAlign.center,
                  fontWeight: FontWeight.bold),
          userList.isEmpty
              ? buildLoadingName(0.2)
              : AutoText(
                  width: width * 0.65,
                  text: "${userList[0]['phone']}",
                  fontSize: 12,
                  color: Colors.grey.shade300,
                  text_align: TextAlign.center,
                  fontWeight: FontWeight.bold,
                )
        ],
      ),
    );
  }

  Widget buildButtonEdit() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return userList.isEmpty
        ? buildLoadingEditButton()
        : Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.3,
            height: height * 0.04,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return EditProfileScreen(
                      user_id: userList[0]['user_id'].toString(),
                      firstname: userList[0]['first_name'],
                      lastname: userList[0]['last_name'],
                      email: userList[0]['email'],
                      phone: userList[0]['phone'],
                      img: userList[0]['user_image']);
                }));
              },
              child: Center(
                child: AutoText(
                  color: Color(0xFF527DAA),
                  fontSize: 14,
                  text: 'Edit profile',
                  text_align: TextAlign.center,
                  width: width * 0.29,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }

  Widget buildReceived_order() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return userList.isEmpty
        ? buildButtonLogout()
        : Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.8,
            height: height * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ReceivedOrderScreen();
                }));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoText(
                    color: Color(0xFF527DAA),
                    fontSize: 16,
                    text: 'Received Order',
                    text_align: TextAlign.center,
                    width: width * 0.45,
                    fontWeight: FontWeight.bold,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF527DAA),
                  )
                ],
              ),
            ),
          );
  }

  Widget buildHistory_order() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return userList.isEmpty
        ? buildButtonLogout()
        : Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.8,
            height: height * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return HistoryScreen();
                }));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoText(
                    color: Color(0xFF527DAA),
                    fontSize: 16,
                    text: 'History Order',
                    text_align: TextAlign.center,
                    width: width * 0.45,
                    fontWeight: FontWeight.bold,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF527DAA),
                  )
                ],
              ),
            ),
          );
  }

  Widget buildButtonReport() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return userList.isEmpty
        ? buildLoadingReport()
        : Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.8,
            height: height * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ReportScreen();
                }));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoText(
                    color: Color(0xFF527DAA),
                    fontSize: 16,
                    text: 'Report',
                    text_align: TextAlign.center,
                    width: width * 0.29,
                    fontWeight: FontWeight.bold,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF527DAA),
                  )
                ],
              ),
            ),
          );
  }

  Widget buildButtonLogout() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return userList.isEmpty
        ? buildLoadingLogout()
        : Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.8,
            height: height * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onPressed: () {
                showdialogLogout();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoText(
                    color: Color(0xFF527DAA),
                    fontSize: 16,
                    text: 'Logout',
                    text_align: TextAlign.center,
                    width: width * 0.29,
                    fontWeight: FontWeight.bold,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF527DAA),
                  )
                ],
              ),
            ),
          );
  }

  Widget buildLoadingProfile() {
    double width = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white60,
      child: CircleAvatar(
        radius: width * 0.18,
      ),
    );
  }

  Widget buildLoadingName(double? width2) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white60,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: height * 0.003),
        width: width * width2!,
        height: height * 0.017,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget buildLoadingEditButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white60,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: height * 0.003),
        width: width * 0.3,
        height: height * 0.04,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget buildLoadingReport() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white60,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: height * 0.01),
        width: width * 0.8,
        height: height * 0.08,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget buildLoadingLogout() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white60,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: height * 0.01),
        width: width * 0.8,
        height: height * 0.08,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  showdialogLogout() {
    double height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          "Do you want logout?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        children: [
          SizedBox(
            height: height * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    primary: Colors.blue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  onPressed: () {
                    logout();
                  },
                  child: Text('yes'),
                ),
                SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    primary: Colors.red,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('no'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
