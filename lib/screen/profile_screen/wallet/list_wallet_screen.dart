import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/color.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListWalletScreen extends StatefulWidget {
  const ListWalletScreen({super.key});

  @override
  State<ListWalletScreen> createState() => _ListWalletScreenState();
}

class _ListWalletScreenState extends State<ListWalletScreen> {
  List historyList = [];
  String? user_id;

  get_wallet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response =
        await http.get(Uri.parse("$ipcon/get_wallet_history/$user_id"));
    var data = json.decode(response.body);
    setState(() {
      historyList = data;
    });
  }

  @override
  void initState() {
    get_wallet();
    super.initState();
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
          text: 'List', text_align: null, width: null,
        ),
      ),
      body: historyList.isEmpty
          ? Center(child: CircularProgressIndicator(color: blue))
          : Container(
              width: width,
              height: height,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: width,
                          height: height * 0.08,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.2, color: Colors.grey)),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.02),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoText(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: null,
                                      text:
                                          '${historyList[index]['wallet_status_name']}', text_align: null, width: null,
                                    ),
                                    historyList[index]['wallet_status_id'] == 1
                                        ? AutoText(
                                            color: Colors.green,
                                            fontSize: 16,
                                            fontWeight: null,
                                            text:
                                                '+ ${historyList[index]['wallet_amount']}', width: null, text_align: null,
                                          )
                                        : AutoText(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: null,
                                            text:
                                                '- ${historyList[index]['wallet_amount']}', width: null, text_align: null,
                                          )
                                  ],
                                ),
                                AutoText(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: null,
                                  text:
                                      '${historyList[index]['wallet_date']} ${historyList[index]['wallet_time']}', width: null, text_align: null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
