import 'dart:convert';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/profile_screen/wallet/add_wallet_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/wallet/list_wallet_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/wallet/withdraw_wallet_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/color.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? user_id;
  List walletList = [];

  get_wallet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response = await http.get(Uri.parse("$ipcon/get_wallet/$user_id"));
    var data = json.decode(response.body);
    setState(() {
      walletList = data;
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
          text: 'Wallet', text_align: null, width: null,
        ),
      ),
      body: walletList.isEmpty
          ? Center(child: CircularProgressIndicator(color: blue))
          : Container(
              width: width,
              height: height,
              child: Column(children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.03),
                    child: Column(
                      children: [
                        AutoText(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          text: 'Wallet balance', text_align: null, width: null,
                        ),
                        SizedBox(height: height * 0.02),
                        AutoText(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          text: '${walletList[0]['wallet_total']} ฿', text_align: null, width: null,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildIcon("withdraw", Icons.payment),
                    buildIcon("top up", Icons.add_card),
                    buildIcon("list", Icons.access_time)
                  ],
                ),
                Divider(),
              ]),
            ),
    );
  }

  Widget buildIcon(String? text, IconData icon) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (text == "top up") {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return AddWalletScreen(
              wallet_id: '${walletList[0]['wallet_id']}',
              wallet_total: '${walletList[0]['wallet_total']}',
            );
          })).then((value) => get_wallet());
        } else if (text == "withdraw") {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return WithDrawWalletScreen(
                wallet_id: '${walletList[0]['wallet_id']}',
                wallet_total: '${walletList[0]['wallet_total']}');
          })).then((value) => get_wallet());
        } else if (text == "list") {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ListWalletScreen();
          })).then((value) => get_wallet());
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: Colors.black,
            ),
            AutoText(
              color: Colors.black.withOpacity(0.8),
              fontSize: 12,
              fontWeight: null,
              text: '$text', text_align: null, width: null,
            ),
          ],
        ),
      ),
    );
  }
}
