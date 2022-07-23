// ignore_for_file: must_be_immutable

import 'package:barg_rider_app/ipcon.dart';
import 'package:flutter/material.dart';

class ShowBigImg extends StatefulWidget {
  String? img;
  ShowBigImg({required this.img});

  @override
  State<ShowBigImg> createState() => _ShowBigImgState();
}

class _ShowBigImgState extends State<ShowBigImg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: Image.network("$path_img/${widget.img}"))),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.highlight_remove,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
