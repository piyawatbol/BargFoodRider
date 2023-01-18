import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Toast_Custom(String? text, Color? color) {
  Fluttertoast.showToast(
    msg: "$text",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    backgroundColor: color,
    textColor: Colors.white,
    fontSize: 16,
  );
}
