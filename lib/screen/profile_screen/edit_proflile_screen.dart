// ignore_for_file: prefer_const_constructors_in_immutables, non_constant_identifier_names, unnecessary_brace_in_string_interps, must_be_immutable, unused_local_variable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
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

  update_user() async {
    final response = await http.patch(
      Uri.parse('$ipcon/edit_img_user/${widget.user_id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "first_name": firstname!.text,
        "last_name": lastname!.text,
        "email": email!.text,
        "phone": phone!.text,
      }),
    );
    print(response.body);
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "duplicate email") {
        print('เมลซ้ำ');
      } else {
        Navigator.pop(context);
      }
    }
  }

  update_img() async {
    final uri = Uri.parse("$ipcon/upload");
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

  BuildCirCle(ImageProvider<Object>? backgroundImage) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 83,
          backgroundColor: Colors.white,
          child: CircleAvatar(radius: 80, backgroundImage: backgroundImage),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
              radius: 23,
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
                        return showmodal1();
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

  showmodal1() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    blurRadius: 2, color: Colors.black26, offset: Offset(2, 5))
              ],
            ),
            child: Center(
                child: GestureDetector(
                    onTap: () {
                      pickCamera();
                    },
                    child: Text(
                      "ถ่ายรูปภาพ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.025,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    blurRadius: 2, color: Colors.black26, offset: Offset(2, 5))
              ],
            ),
            child: Center(
                child: GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Text(
                      "เลือกรูปภาพ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))),
          )
        ],
      ),
    );
  }

  BulidData(String text, TextEditingController? controller) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35),
          width: double.infinity,
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Container(
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 3,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    setTextController();
    super.initState();
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
                          vertical: 20, horizontal: 12),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 35,
                            ),
                          ),
                          Text(
                            "EditProfile",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    image != null
                        ? BuildCirCle(FileImage(image!))
                        : widget.img == "" || widget.img == null
                            ? BuildCirCle(
                                AssetImage("assets/images/profile.png"))
                            : BuildCirCle(
                                NetworkImage("$path_img/${widget.img}")),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    BulidData("FirstName", firstname),
                    BulidData("Lastname", lastname),
                    BulidData("Email", email),
                    BulidData("Phone", phone),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.black,
                            primary: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              statusLoading = true;
                            });
                            if (image == null) {
                              update_user();
                            } else {
                              update_user();
                              update_img();
                            }
                          },
                          child: Text('Save'),
                        ),
                      ),
                    )
                  ],
                )),
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
