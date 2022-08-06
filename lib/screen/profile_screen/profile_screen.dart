// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/home_screen.dart';
import 'package:barg_rider_app/screen/login_system/login_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/edit_proflile_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/report_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/show_big_img.dart';
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

  get_id() async {
    String? user_id;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    if (user_id == "" || user_id == null) {
      return userList;
    } else {
      final response = await http.get(Uri.parse("$ipcon/get_id/$user_id"));
      var data = json.decode(response.body);
      if (this.mounted) {
        setState(() {
          userList = data;
        });
      }
      return userList;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Profile",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: get_id(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              snapshot.data[index]['user_image'] == "" ||
                                      snapshot.data[index]['user_image'] == null
                                  ? CircleAvatar(
                                      radius: 72,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                          radius: 70,
                                          backgroundImage: AssetImage(
                                              "assets/images/profile.png")),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return ShowBigImg(
                                              img: snapshot.data[index]
                                                  ['user_image']);
                                        }));
                                      },
                                      child: CircleAvatar(
                                        radius: 75,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              "$path_img/users/${snapshot.data[index]['user_image']}"),
                                          radius: 70,
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: AutoSizeText(
                                  "${snapshot.data[index]['first_name']}  ${snapshot.data[index]['last_name']}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.white),
                                  minFontSize: 15,
                                  maxLines: 2,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: AutoSizeText(
                                    "${snapshot.data[index]['email']}  ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                    minFontSize: 12,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              snapshot.data[index]['phone'] == ""
                                  ? Text("no telephone number")
                                  : Text("${snapshot.data[index]['phone']}",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white)),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.045,
                                child: RaisedButton(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return EditProfileScreen(
                                          user_id: snapshot.data[index]
                                                  ['user_id']
                                              .toString(),
                                          firstname: snapshot.data[index]
                                              ['first_name'],
                                          lastname: snapshot.data[index]
                                              ['last_name'],
                                          email: snapshot.data[index]['email'],
                                          phone: snapshot.data[index]['phone'],
                                          img: snapshot.data[index]
                                              ['user_image']);
                                    }));
                                  },
                                  child: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                        color: Color(0xff3f3f3f),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    BuildBox(
                                        "Status in progress", HomeScreen()),
                                    BuildBox("Report", ReportScreen()),
                                    BuildBox("Logout", null)
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    );
                  } else {
                    return LoadingPage();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget LoadingPage() {
    return Column(
      children: [
        Shimmer.fromColors(
            baseColor: Colors.white70,
            highlightColor: Colors.white10,
            child: CircleAvatar(
              radius: 75,
              backgroundColor: Colors.black38,
            )),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Shimmer.fromColors(
          baseColor: Colors.white70,
          highlightColor: Colors.white10,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.36,
            height: MediaQuery.of(context).size.height * 0.03,
            decoration: BoxDecoration(
              color: Colors.black38,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Shimmer.fromColors(
            baseColor: Colors.white70,
            highlightColor: Colors.white10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.29,
              height: MediaQuery.of(context).size.height * 0.016,
              decoration: BoxDecoration(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.white70,
          highlightColor: Colors.white10,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.24,
            height: MediaQuery.of(context).size.height * 0.016,
            decoration: BoxDecoration(
              color: Colors.black38,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Shimmer.fromColors(
          baseColor: Colors.white70,
          highlightColor: Colors.white10,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.38,
            height: MediaQuery.of(context).size.height * 0.047,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.black38,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.035,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.white70,
                highlightColor: Colors.white10,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.073,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black38,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Shimmer.fromColors(
                baseColor: Colors.white70,
                highlightColor: Colors.white10,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.073,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  showdialogLogout() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
            child: Text(
          "Do you want to log out?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        children: [
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

  Widget BuildBox(String? text, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (page == null) {
          showdialogLogout();
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return page;
          }));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$text",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff3f3f3f),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xff3f3f3f),
              )
            ],
          ),
        ),
      ),
    );
  }
}
