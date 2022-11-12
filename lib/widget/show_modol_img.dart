// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ShowMoDalImg extends StatelessWidget {
  Function pickCamera;
  Function pickImage;
  ShowMoDalImg({required this.pickCamera, required this.pickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.008,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(30)),
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade400,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  )),
              title: Text(
                "Take photo",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {
                pickCamera();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade400,
                child: Icon(
                  Icons.photo,
                  color: Colors.black,
                ),
              ),
              title: Text("Choose from library",
                  style: TextStyle(
                    fontSize: 18,
                  )),
              onTap: () {
                pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
