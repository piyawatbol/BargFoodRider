// ignore_for_file: prefer_const_constructors_in_immutables, non_constant_identifier_names, unnecessary_brace_in_string_interps, must_be_immutable, unused_local_variable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:io';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/profile_screen/change_email_phone/check_pass_email_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/change_email_phone/check_pass_phone_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:barg_rider_app/widget/show_modol_img.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  String? user_id;
  String? firstname;
  String? lastname;
  String? phone;
  String? email;
  String? img;
  EditProfileScreen(
      {required this.user_id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.phone,
      required this.img});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? image;
  bool statusLoading = false;
  TextEditingController? firstname;
  TextEditingController? lastname;
  TextEditingController? email;
  TextEditingController? phone;

  setTextController() async {
    firstname = TextEditingController(text: widget.firstname);
    lastname = TextEditingController(text: widget.lastname);
    email = TextEditingController(text: widget.email);
    phone = TextEditingController(text: widget.phone);
  }

  edit_user() async {
    final response = await http.patch(
      Uri.parse('$ipcon/edit_user/${widget.user_id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "first_name": firstname!.text,
        "last_name": lastname!.text,
      }),
    );
    print(response.body);
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "update success") {
        Navigator.pop(context);
      }
    }
  }

  update_img() async {
    final uri = Uri.parse("$ipcon/edit_img_user");
    var request = http.MultipartRequest('POST', uri);
    var img = await http.MultipartFile.fromPath("img", image!.path);
    request.files.add(img);
    request.fields['id'] = widget.user_id.toString();
    var response = await request.send();
    if (response.statusCode == 200) {
      print("upload images success");
    } else {
      print("Not upload images");
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
  }

  Future pickCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    setTextController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
                    BackArrowButton(text: "Edit Profile", width2: 0.24),
                    SizedBox(height: height * 0.02),
                    buildProfileIcon(),
                    SizedBox(height: height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.022, horizontal: width * 0.08),
                      child: Row(
                        children: [
                          AutoText(
                              width: width * 0.3,
                              text: "My Profile",
                              fontSize: 28,
                              color: Colors.white,
                              text_align: TextAlign.left,
                              fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                    BulidBox1("Firstname", firstname),
                    BulidBox1("Lastname", lastname),
                    BuildBox2(
                        "Email", "${widget.email}", CheckPassEmailScreen()),
                    BuildBox2(
                        "Phone", "${widget.phone}", CheckPassPhoneScreen()),
                    buildButtonSave()
                  ],
                )),
              ),
            ),
            LoadingPage(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildProfileIcon() {
    return image != null
        ? BuildCirCle(FileImage(image!))
        : widget.img == "" || widget.img == null
            ? BuildCirCle(AssetImage("assets/images/profile.png"))
            : BuildCirCle(NetworkImage("$path_img/users/${widget.img}"));
  }

  BuildCirCle(ImageProvider<Object>? backgroundImage) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        CircleAvatar(
          radius: width * 0.18,
          backgroundColor: Colors.white,
          child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: width * 0.16,
              backgroundImage: backgroundImage),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
              radius: width * 0.055,
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      barrierColor: Colors.black26,
                      context: this.context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      builder: (context) {
                        return ShowMoDalImg(
                            pickCamera: pickCamera, pickImage: pickImage);
                      });
                },
                icon: Icon(
                  Icons.photo,
                  color: Colors.black,
                ),
              )),
        ),
      ],
    );
  }

  Widget BulidBox1(String text, TextEditingController? controller) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.004),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
              width: width * 0.17,
              text: text,
              fontSize: 14,
              color: Colors.white,
              text_align: TextAlign.left,
              fontWeight: FontWeight.w600),
          Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.002),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.white,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.white,
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

  Widget BuildBox2(String? text, String? message, Widget? page) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.004),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            width: width * 0.11,
            text: text,
            fontSize: 14,
            color: Colors.white,
            text_align: TextAlign.left,
            fontWeight: FontWeight.w600,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.004),
            height: MediaQuery.of(context).size.height * 0.054,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: width * 0.045),
                Container(
                  width: width * 0.64,
                  child: Text(
                    "$message",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return page!;
                            }));
                          },
                          icon: Icon(Icons.edit)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonSave() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.05),
      width: width * 0.3,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          if (image == null) {
            setState(() {
              statusLoading = true;
            });
            edit_user();
          } else {
            setState(() {
              statusLoading = true;
            });
            update_img();
            edit_user();
          }
        },
        child: Center(
          child: AutoText(
            color: Color(0xFF527DAA),
            fontSize: 14,
            text: 'Save',
            text_align: TextAlign.center,
            width: width * 0.29,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
