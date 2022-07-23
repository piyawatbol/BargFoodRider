// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_unnecessary_containers
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:barg_rider_app/screen/home_screen/go_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoStoreScreen extends StatefulWidget {
  GoStoreScreen({Key? key}) : super(key: key);
  @override
  State<GoStoreScreen> createState() => _GoStoreScreenState();
}

class _GoStoreScreenState extends State<GoStoreScreen> {
  GoogleMapController? mapController;
  Position? driverLocation;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        // color: Color(0xff71B5F4),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder(
                future: _getLocation(),
                builder: (BuildContext context,
                    AsyncSnapshot<Position?> snapshot) {
                  if (snapshot.hasData) {
                    return GoogleMap(
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        zoom: 18,
                        target: LatLng(driverLocation!.latitude,
                            driverLocation!.longitude),
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
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 35,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Color(0xff71B5F4),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Text(
                          "ที่อยู่ลูกค้า xxxxxxxxxxxxxxxxx",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              primary: Colors.green,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return GoCustomerScreen();
                              }));
                            },
                            child: Text('รับอาหาร'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
