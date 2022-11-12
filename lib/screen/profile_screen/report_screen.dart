// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:io';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/show_modol_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  File? image;
  TextEditingController report = TextEditingController();

  pickImage() async {
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

  pickCamera() async {
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
              BackArrowButton(text: "Report", width2: 0.17),
              buildImage(),
              SizedBox(height: height * 0.035),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.015, horizontal: width * 0.015),
                child: Row(
                  children: [
                    AutoText(
                      width: width * 0.37,
                      text: "Details Problem",
                      fontSize: 18,
                      color: Colors.white,
                      text_align: TextAlign.left,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              buildInputBox(report),
              buildButtonSave()
            ],
          ),
        )),
      ),
    );
  }

  Widget buildImage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            barrierColor: Colors.black26,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            builder: (context) {
              return ShowMoDalImg(
                pickCamera: pickCamera,
                pickImage: pickImage,
              );
            });
      },
      child: image == null
          ? Container(
              width: width * 0.9,
              height: height * 0.24,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 4),
                ),
              ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Image.asset(
                "assets/images/add.png",
                color: Colors.blue,
              ))
          : Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.24,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 4),
                ),
              ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Widget buildInputBox(TextEditingController? controller) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.23,
      width: width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(3, 5),
          ),
        ],
      ),
      child: TextFormField(
        maxLines: 15,
        minLines: 1,
        controller: controller,
        style: TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 24),
            hintStyle: TextStyle(color: Colors.white54)),
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
        onPressed: () {},
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
