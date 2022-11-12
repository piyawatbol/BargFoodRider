// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatefulWidget {
  bool? statusLoading;
  LoadingPage({required this.statusLoading});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          widget.statusLoading = false;
        });
      },
      child: Visibility(
        visible: widget.statusLoading == true ? true : false,
        child: Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: width,
                height: height,
                color: Colors.white10,
              ),
              Positioned(
                child: Container(
                  width: width * 0.25,
                  height: height * 0.12,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: SpinKitFadingCircle(
                    color: Color(0xFF398AE5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
