// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_print, unused_element, dead_code, non_constant_identifier_names
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/go_store_screen.dart';
import 'package:barg_rider_app/screen/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  Position? driverLocation;
  bool value = true;
  List userList = [];
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

  get_id() async {
    String? user_id;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    if (user_id == null || user_id == "") {
      return userList;
    }
    final response = await http.get(Uri.parse("$ipcon/get_id/$user_id"));
    var data = json.decode(response.body);

    if (this.mounted) {
      setState(() {
        userList = data;
      });
      return userList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
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
                    target: LatLng(
                        driverLocation!.latitude, driverLocation!.longitude),
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ProfileScreen();
            }));
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                    future: get_id(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      int index = 0;
                      if (snapshot.hasData) {
                        return snapshot.data[index]['user_image'] == null ||
                                snapshot.data[index]['user_image'] == ""
                            ? CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/profile.png'),
                                  radius: 40,
                                ),
                              )
                            : CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "$path_img/${snapshot.data[index]['user_image']}"),
                                  radius: 40,
                                ),
                              );
                      } else {
                        return Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[100]!,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.black38,
                            ));
                      }
                    },
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Switch.adaptive(
                        activeColor: Colors.green,
                        inactiveTrackColor: Colors.red.shade500,
                        inactiveThumbColor: Colors.red.shade300,
                        value: value,
                        onChanged: (value) {
                          setState(() {
                            this.value = value;
                          });
                          print(value);
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Color(0xff71B5F4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(3, 5),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Text("ชื่อร้าน xxx xxxx xxx"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ระยะทาง x กิโลเมตร"),
                                Text("ค่าส่ง 0.0 บาท")
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      onPrimary: Colors.white,
                                      primary: Colors.red,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text('ยกเลิก'),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      onPrimary: Colors.white,
                                      primary: Colors.green,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return GoStoreScreen();
                                      }));
                                    },
                                    child: Text('รับงาน'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    ));
  }
}
