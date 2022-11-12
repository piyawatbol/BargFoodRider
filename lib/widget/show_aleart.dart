import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:flutter/material.dart';

buildShowAlert(context, String? text) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Center(
          child: Text(
        "$text",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
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
              text: 'OK',
              text_align: TextAlign.center,
              width: width * 0.07,
            ),
          ),
        ),
      ],
    ),
  );
}
