import 'dart:convert';
import 'package:barg_rider_app/screen/home_screen/go_customer_screen.dart';
import 'package:barg_rider_app/screen/home_screen/go_store_screen.dart';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivedOrderScreen extends StatefulWidget {
  ReceivedOrderScreen({Key? key}) : super(key: key);

  @override
  State<ReceivedOrderScreen> createState() => _ReceivedOrderScreenState();
}

class _ReceivedOrderScreenState extends State<ReceivedOrderScreen> {
  List requestList = [];
  bool status_user = true;
  List userList = [];
  List order_List = [];
  List amountList = [];
  List priceList = [];
  List orderList = [];
  int sum_amount = 0;
  int sum_price = 0;
  String? request_id;
  bool statusLoading = false;
  String? user_id;

  get_request_recived() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response =
        await http.get(Uri.parse("$ipcon/get_request_recived/$user_id"));
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        requestList = data;
      });
    }
  }

  get_sum_amout_price(String? _order_id, index) async {
    final response = await http.get(Uri.parse("$ipcon/get_order/$_order_id"));
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        order_List = data;
        sum_amount = 0;
        sum_price = 0;
      });
    }
    for (var i = 0; i < order_List.length; i++) {
      int amount = int.parse(order_List[i]['amount']);
      int price = int.parse(order_List[i]['price']);

      sum_amount = sum_amount + amount;
      sum_price = sum_price + price;
    }
    if (amountList.length < requestList.length) {
      amountList.add('$sum_amount');
      priceList.add('$sum_price');
    } else {
      amountList[index] = sum_amount.toString();
      priceList[index] = sum_price.toString();
    }
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
                BackArrowButton(text: 'Received Order', width2: 0.4),
                buildListOrder()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListOrder() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: get_request_recived(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return SizedBox(
          height: height * 0.8,
          child: requestList.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  itemCount: requestList.length,
                  itemBuilder: (BuildContext context, int index) {
                    get_sum_amout_price(requestList[index]['order_id'], index);
                    return GestureDetector(
                      onTap: () {
                        if (requestList[index]['status'] == '4') {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return GoStoreScreen(
                                request_id:
                                    '${requestList[index]['request_id']}');
                          }));
                        } else if (requestList[index]['status'] == '6') {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return GotoCustomer(
                              request_id: '${requestList[index]['request_id']}',
                            );
                          }));
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: height * 0.005, horizontal: width * 0.02),
                        width: width,
                        height: height * 0.17,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(3, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.all(8),
                              width: width * 0.3,
                              height: height * 0.16,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          "assets/images/store.jpg"))),
                            ),
                            Container(
                              width: width * 0.6,
                              height: height * 0.13,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AutoText(
                                          width: width * 0.14,
                                          text: "Status : ",
                                          fontSize: 14,
                                          color: Colors.black,
                                          text_align: TextAlign.left,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        AutoText(
                                          width: width * 0.3,
                                          text:
                                              "${requestList[index]['order_status_name']}",
                                          fontSize: 14,
                                          color: requestList[index]['status'] ==
                                                  '4'
                                              ? Colors.orange
                                              : Colors.blue,
                                          text_align: TextAlign.left,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                    AutoText2(
                                      width: width * 0.7,
                                      text:
                                          "Store name :  ${requestList[index]['store_name']}",
                                      fontSize: 15,
                                      color: Colors.black,
                                      text_align: TextAlign.left,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    AutoText(
                                      width: width * 0.6,
                                      text:
                                          "Order :  ${requestList[index]['order_id']}",
                                      fontSize: 14,
                                      color: Colors.black,
                                      text_align: TextAlign.left,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    amountList.isEmpty
                                        ? Text("")
                                        : AutoText(
                                            width: width * 0.6,
                                            text: "Item : ${amountList[index]}",
                                            fontSize: 14,
                                            color: Colors.black,
                                            text_align: TextAlign.left,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    priceList.isEmpty
                                        ? Text("")
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  AutoText(
                                                    width: width * 0.12,
                                                    text: "Total : ",
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    text_align: TextAlign.left,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  AutoText(
                                                    width: width * 0.2,
                                                    text:
                                                        "${priceList[index]}฿",
                                                    fontSize: 16,
                                                    color: Colors.green,
                                                    text_align: TextAlign.left,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                              requestList[index]['slip_img'] ==
                                                      ''
                                                  ? AutoText(
                                                      width: width * 0.2,
                                                      text: "ปลายทาง",
                                                      fontSize: 16,
                                                      color: Colors.orange,
                                                      text_align:
                                                          TextAlign.left,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )
                                                  : AutoText(
                                                      width: width * 0.2,
                                                      text: "OR Code",
                                                      fontSize: 16,
                                                      color: Colors.orange,
                                                      text_align:
                                                          TextAlign.left,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
