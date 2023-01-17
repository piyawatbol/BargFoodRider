import 'dart:convert';
import 'package:barg_rider_app/screen/home_screen/go_store_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/profile_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  Position? driverLocation;
  bool status_user = true;
  List userList = [];
  List requestList = [];
  List orderList = [];
  String? request_id;
  bool statusLoading = false;
  String? user_id;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Position?> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    driverLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return driverLocation;
  }

  get_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final response = await http.get(Uri.parse("$ipcon/get_user/$user_id"));
    var data = json.decode(response.body);
    setState(() {
      userList = data;
    });

    return userList;
  }

  get_request() async {
    final response = await http.get(Uri.parse("$ipcon/get_request_rider"));
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        requestList = data;
      });
    }
  }

  status_off() {
    requestList.clear();
  }

  update_request(request_id) async {
    final response = await http.post(
      Uri.parse('$ipcon/update_request_rider'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "request_id": request_id.toString(),
        "status": "4",
        "rider_id": user_id.toString(),
        "rider_lati": driverLocation!.latitude.toString(),
        "rider_longti": driverLocation!.longitude.toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return GoStoreScreen(request_id: '$request_id');
      }));
    }
  }

  get_order(String? _request_id, String? _order_id, String? sum_price,
      String? delivery_fee, String? total) async {
    final response = await http.get(Uri.parse("$ipcon/get_order/$_order_id"));
    var data = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        orderList = data;
        request_id = _request_id;
      });
      setState(() {
        statusLoading = false;
      });
      buildShow(_order_id, sum_price, delivery_fee, total);
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
        child: Stack(
          children: [
            buildMap(),
            buildProfile(),
            buildListOrder(),
            LoadingPage(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.white,
      width: width,
      height: height * 0.5,
      child: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot<Position?> snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target:
                    LatLng(driverLocation!.latitude, driverLocation!.longitude),
              ),
            );
          } else {
            return Container(
              color: Colors.white,
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              )),
            );
          }
        },
      ),
    );
  }

  Widget buildProfile() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.06, vertical: height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ProfileScreen();
                  }));
                },
                child: FutureBuilder(
                  future: get_user(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    return userList.isEmpty
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : userList[0]['user_image'] == ""
                            ? CircleAvatar(
                                radius: width * 0.1,
                                backgroundImage:
                                    AssetImage("assets/images/profile.png"),
                              )
                            : CircleAvatar(
                                radius: width * 0.115,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: width * 0.1,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      "$path_img/users/${userList[0]['user_image']}"),
                                ),
                              );
                  },
                )),
            Transform.scale(
              scale: 1.3,
              child: Switch.adaptive(
                activeColor: Colors.green,
                inactiveTrackColor: Colors.red.shade500,
                inactiveThumbColor: Colors.red.shade300,
                value: status_user,
                onChanged: (value) {
                  setState(() {
                    this.status_user = value;
                  });
                  print(value);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildListOrder() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Positioned(
        bottom: 0,
        child: FutureBuilder(
          future: status_user == true ? get_request() : status_off(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Container(
              width: width,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: height * 0.01),
                itemCount: requestList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      statusLoading = true;
                      get_order(
                          requestList[index]['request_id'].toString(),
                          requestList[index]['order_id'],
                          requestList[index]['sum_price'].toString(),
                          requestList[index]['delivery_fee'].toString(),
                          requestList[index]['total'].toString());
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: height * 0.005, horizontal: width * 0.02),
                      width: width,
                      height: height * 0.13,
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
                                    image:
                                        AssetImage("assets/images/store.jpg"))),
                          ),
                          Container(
                            width: width * 0.6,
                            height: height * 0.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
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
                                Row(
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
                                              "${requestList[index]['total']} ฿",
                                          fontSize: 16,
                                          color: Colors.green,
                                          text_align: TextAlign.left,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        AutoText(
                                          width: width * 0.5,
                                          text:
                                              "payment : ${requestList[index]['buyer_name']}",
                                          fontSize: 14,
                                          color: Colors.black,
                                          text_align: TextAlign.left,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
        ));
  }

  buildShow(order_id, sum_price, delivery_fee, total) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.01, horizontal: width * 0.05),
                  child: Image.asset(
                    'assets/images/cancel.png',
                    width: width * 0.1,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            width: width,
            height: orderList.length <= 2
                ? height * 0.2
                : orderList.length < 8
                    ? height * 0.5
                    : height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.001, horizontal: width * 0.02),
                      child: AutoText(
                        color: Colors.black,
                        fontSize: 16,
                        text: 'Order Details',
                        text_align: TextAlign.center,
                        width: width * 0.29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.005, horizontal: width * 0.03),
                      child: AutoText(
                        color: Colors.black,
                        fontSize: 16,
                        text: '$order_id',
                        text_align: TextAlign.left,
                        width: width * 0.29,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: ListView.builder(
                        itemCount: orderList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.05),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    AutoText2(
                                      color: Colors.black,
                                      fontSize: 16,
                                      text: '${orderList[index]['food_name']}',
                                      text_align: TextAlign.left,
                                      width: width * 0.45,
                                      fontWeight: null,
                                    ),
                                    AutoText2(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      text: '${orderList[index]['detail']}',
                                      text_align: TextAlign.left,
                                      width: width * 0.45,
                                      fontWeight: null,
                                    ),
                                  ],
                                ),
                                AutoText(
                                  color: Colors.black,
                                  fontSize: 16,
                                  text: '${orderList[index]['amount']}',
                                  text_align: TextAlign.right,
                                  width: width * 0.1,
                                  fontWeight: null,
                                ),
                                AutoText(
                                  color: Colors.black,
                                  fontSize: 16,
                                  text: '${orderList[index]['price']}',
                                  text_align: TextAlign.right,
                                  width: width * 0.1,
                                  fontWeight: null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  color: Colors.black,
                  fontSize: 14,
                  text: 'subtotal',
                  text_align: TextAlign.left,
                  width: width * 0.29,
                  fontWeight: FontWeight.w500,
                ),
                AutoText(
                  color: Colors.black,
                  fontSize: 14,
                  text: '$sum_price ฿',
                  text_align: TextAlign.right,
                  width: width * 0.29,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  color: Colors.black,
                  fontSize: 14,
                  text: 'delivery fee',
                  text_align: TextAlign.left,
                  width: width * 0.29,
                  fontWeight: FontWeight.w500,
                ),
                AutoText(
                  color: Colors.black,
                  fontSize: 14,
                  text: '$delivery_fee ฿',
                  text_align: TextAlign.right,
                  width: width * 0.29,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  color: Colors.black,
                  fontSize: 16,
                  text: 'Total',
                  text_align: TextAlign.left,
                  width: width * 0.29,
                  fontWeight: FontWeight.bold,
                ),
                AutoText(
                  color: Colors.green,
                  fontSize: 16,
                  text: '$total ฿',
                  text_align: TextAlign.right,
                  width: width * 0.29,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: width * 0.35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                    onPressed: () {
                      update_request(request_id);
                    },
                    child: AutoText(
                      color: Colors.white,
                      fontSize: 14,
                      text: 'Confirm',
                      text_align: TextAlign.center,
                      width: width * 0.29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: width * 0.35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: AutoText(
                      color: Colors.white,
                      fontSize: 14,
                      text: 'Cancel',
                      text_align: TextAlign.center,
                      width: width * 0.29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonConfirm(String? request_id) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.22,
      height: height * 0.035,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          setState(() {
            statusLoading = true;
          });
          update_request(request_id);
        },
        child: Center(
          child: AutoText(
            color: Colors.white,
            fontSize: 14,
            text: 'Confirm',
            text_align: TextAlign.center,
            width: width * 0.29,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
