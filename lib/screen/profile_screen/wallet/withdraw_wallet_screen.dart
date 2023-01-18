// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/color.dart';
import 'package:barg_rider_app/widget/toast_custom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widget/loadingPage.dart';

class WithDrawWalletScreen extends StatefulWidget {
  String? wallet_id;
  String? wallet_total;
  WithDrawWalletScreen({required this.wallet_id, required this.wallet_total});

  @override
  State<WithDrawWalletScreen> createState() => _WithDrawWalletScreenState();
}

class _WithDrawWalletScreenState extends State<WithDrawWalletScreen> {
  TextEditingController money = TextEditingController();
  TextEditingController bank = TextEditingController();
  String? select;
  String? user_id;
  bool statusLoading = false;

  sub_wallet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response = await http.patch(
      Uri.parse('$ipcon/sub_wallet/$user_id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "wallet_id": widget.wallet_id!,
        "wallet_amount": money.text,
        "banking": bank.text,
        "wallet_total": widget.wallet_total!
      }),
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "Withdraw money wallet Success") {
        Toast_Custom("Add Wallet Success", Colors.green);
        Navigator.pop(context);
      } else if (data == "The amount in the wallet is insufficient") {
        Toast_Custom("$data", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: AutoText(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          text: 'Withdraw Wallet',
          text_align: null,
          width: null,
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.031, vertical: height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoText(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: null,
                        text: 'Top up amount',
                        text_align: null,
                        width: null,
                      ),
                      Row(
                        children: [
                          AutoText(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: null,
                            text: 'amount',
                            text_align: null,
                            width: null,
                          ),
                          SizedBox(width: 5),
                          AutoText(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: null,
                            text: '( balance ${widget.wallet_total} ฿ )',
                            width: null,
                            text_align: null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildMoney("100"),
                    buildMoney("200"),
                    buildMoney("300"),
                    buildMoney("500"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildMoney("800"),
                    buildMoney("1000"),
                    buildMoney("1500"),
                    buildMoney("2000"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        cursorColor: Colors.black,
                        controller: money,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        '( Can top up each time 100.00 - 45,000.00 bath )',
                        style: TextStyle(color: Colors.black38),
                      ),
                      SizedBox(height: height * 0.01),
                      AutoText(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: null,
                        text: 'Banking',
                        text_align: null,
                        width: null,
                      ),
                      TextField(
                        cursorColor: Colors.black,
                        controller: bank,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                buildButtonContinue()
              ],
            ),
          ),
          LoadingPage(statusLoading: statusLoading)
        ],
      ),
    );
  }

  Widget buildMoney(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        setState(() {
          money = TextEditingController(text: text);
          select = text;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: width * 0.01, vertical: height * 0.005),
        width: width * 0.22,
        height: height * 0.06,
        decoration: BoxDecoration(
            border: Border.all(
                width: 3,
                color: select == text ? blue : Colors.grey.withOpacity(0.3))),
        child: Center(
          child: AutoText(
            color: Colors.black,
            fontSize: 18,
            fontWeight: null,
            text: '$text',
            text_align: null,
            width: null,
          ),
        ),
      ),
    );
  }

  Widget buildButtonContinue() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.02),
          width: width * 0.9,
          height: height * 0.05,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: blue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            onPressed: () {
              if (money.text == "") {
                Toast_Custom("Please Enter Balance", Colors.red);
              } else if (bank.text == "") {
                Toast_Custom("Please Insert Banking", Colors.red);
              } else {
                setState(() {
                  setState(() {
                    statusLoading = true;
                  });
                });
                sub_wallet();
              }
            },
            child: Center(
              child: AutoText(
                color: Colors.white,
                fontSize: 14,
                text: 'Continue',
                fontWeight: FontWeight.bold,
                text_align: null,
                width: null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
