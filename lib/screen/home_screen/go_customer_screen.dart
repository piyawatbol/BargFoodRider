// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_unnecessary_containers, must_be_immutable
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:barg_rider_app/ipcon.dart';
import 'package:barg_rider_app/screen/home_screen/home_screen.dart';
import 'package:barg_rider_app/widget/auto_size_text.dart';
import 'package:barg_rider_app/widget/back_button.dart';
import 'package:barg_rider_app/widget/color.dart';
import 'package:barg_rider_app/widget/loadingPage.dart';
import 'package:barg_rider_app/widget/show_aleart.dart';
import 'package:barg_rider_app/widget/show_modol_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class GotoCustomer extends StatefulWidget {
  String? request_id;
  GotoCustomer({required this.request_id});
  @override
  State<GotoCustomer> createState() => _GotoCustomerState();
}

class _GotoCustomerState extends State<GotoCustomer> {
  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  List requestList = [];
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyB69O3HUJkJwXLuvu3jfqgW7EUOzGvVxlI";
  Position? driverLocation;
  Timer? _timer;
  double? store_lat;
  double? store_long;
  LatLng? startLocation;
  LatLng? endLocation;
  double latmap = 0.0;
  double longmap = 0.0;
  double? zoom;
  double? distance;
  late BitmapDescriptor mapMaker;
  List orderList = [];
  bool statusLoading = false;
  File? image;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Position?> getLocation() async {
    driverLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return driverLocation;
  }

  get_request_one() async {
    final response = await http
        .get(Uri.parse("$ipcon/get_request_one/${widget.request_id}"));
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        statusLoading = false;
        requestList = data;
        store_lat = double.parse(requestList[0]['latitude']);
        store_long = double.parse(requestList[0]['longtitude']);
      });
    }

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/location_marker.png', 130);
    if (this.mounted) {
      setState(() {
        startLocation =
            LatLng(driverLocation!.latitude, driverLocation!.longitude);
        endLocation = LatLng(store_lat!, store_long!);
        latmap = driverLocation!.latitude + store_lat!;
        latmap = latmap / 2;
        longmap = driverLocation!.longitude + store_long!;
        longmap = longmap / 2;
        double cal = calculateDistance(store_lat!, store_long!);
        check_zoom(cal);
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: zoom!,
              target: LatLng(latmap, longmap),
            ),
          ),
        );
        markers.add(
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(store_lat!, store_long!),
            infoWindow: InfoWindow(
              title: 'Destination Point ',
              snippet: 'Destination Marker',
            ),
            icon: BitmapDescriptor.fromBytes(markerIcon),
          ),
        );
        add_maker_polyline();
      });
    }
  }

  add_maker_polyline() async {
    if (this.mounted) {
      setState(
        () {
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: zoom!,
                target: LatLng(latmap, longmap),
              ),
            ),
          );
        },
      );
    }
    await getDirections();
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation!.latitude, startLocation!.longitude),
      PointLatLng(endLocation!.latitude, endLocation!.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  check_zoom(double cal) {
    if (cal <= 0.3) {
      return zoom = 17;
    } else if (cal <= 1) {
      return zoom = 16;
    } else if (cal <= 2) {
      return zoom = 15;
    } else if (cal <= 3) {
      return zoom = 14;
    } else if (cal <= 4) {
      return zoom = 13;
    } else if (cal <= 5) {
      return zoom = 12;
    } else if (cal <= 6) {
      return zoom = 11;
    } else if (cal <= 7) {
      return zoom = 10;
    } else if (cal <= 8) {
      return zoom = 9;
    } else if (cal <= 9) {
      return zoom = 8;
    }
  }

  calculateDistance(double lat, double long) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat - double.parse(driverLocation!.latitude.toString())) * p) / 2 +
        c(double.parse(driverLocation!.latitude.toString()) * p) *
            c(lat * p) *
            (1 -
                c((double.parse(driverLocation!.longitude.toString()) - long) *
                    p)) /
            2;

    distance = double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2));
    return distance;
  }

  get_order(String? _order_id) async {
    final response = await http.get(Uri.parse("$ipcon/get_order/$_order_id"));
    var data = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        orderList = data;

        statusLoading = false;
      });
      setState(() {
        showModalBottomSheet(
          barrierColor: Colors.black26,
          context: this.context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          builder: (context) {
            return buildButtomSheet();
          },
        );
      });
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
    Navigator.pop(context);
    send_img_order();
  }

  Future pickCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
  }

  send_img_order() {
    showModalBottomSheet(
      barrierColor: Colors.black26,
      context: this.context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return buildButtomSheet2();
      },
    );
  }

  success_requst() async {
    final uri = Uri.parse("$ipcon/request_success");
    var request = http.MultipartRequest('POST', uri);
    var img = await http.MultipartFile.fromPath("img", image!.path);
    request.files.add(img);
    request.fields['request_id'] = widget.request_id.toString();
    var response = await request.send();
    if (response.statusCode == 200) {
      update_request();
    } else {
      print("Not upload images");
    }
  }

  update_request() async {
    final response = await http.post(
      Uri.parse('$ipcon/update_request'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "request_id": '${widget.request_id}',
        "status": "7",
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }), (route) => false);
    }
  }

  update_location() async {
    final response = await http.post(
      Uri.parse('$ipcon/update_rider_location'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "request_id": '${widget.request_id}',
        "rider_lati": driverLocation!.latitude.toString(),
        "rider_longti": driverLocation!.longitude.toString(),
      }),
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "update success") {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    statusLoading = true;
    get_request_one();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await getLocation();
      get_request_one();
      update_location();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
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
            buildBackbutton(),
            LoadingPage(statusLoading: statusLoading)
          ],
        ),
      ),
      floatingActionButton: requestList.isEmpty
          ? Container()
          : SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              spaceBetweenChildren: 5,
              children: [
                SpeedDialChild(
                    child: Icon(Icons.check),
                    label: 'Success Order',
                    onTap: () {
                      send_img_order();
                    }),
                SpeedDialChild(
                    child: Icon(Icons.list_alt_outlined),
                    label: 'Detail',
                    onTap: () {
                      setState(() {
                        statusLoading = true;
                      });
                      get_order(requestList[0]['order_id'].toString());
                    }),
                SpeedDialChild(
                    child: Icon(Icons.map_outlined),
                    label: 'Open google map',
                    onTap: () {
                      final Uri url = Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=$store_lat,$store_long");
                      launchUrl(url);
                    })
              ],
            ),
    );
  }

  Widget buildMap() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot<Position?> snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              markers: markers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              polylines: Set<Polyline>.of(polylines.values),
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
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget buildBackbutton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
          margin: EdgeInsets.all(20),
          width: width,
          height: height * 0.09,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF61A4F1), Color(0xFF478De0), Color(0xFF398AE5)],
            ),
          ),
          child: BackArrowButton(text: "Go To Customer", width2: 0.35)),
    );
  }

  Widget buildButtomSheet() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                height: height * 0.01,
                width: width * 0.15,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30)),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03, vertical: height * 0.003),
                child: Image.asset(
                  "assets/images/location.png",
                  width: width * 0.04,
                  height: height * 0.02,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                width: width * 0.9,
                child: AutoText3(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  fontWeight: null,
                  text:
                      '${requestList[0]['store_detail']} ${requestList[0]['store_house_number']} ${requestList[0]['store_county']} ${requestList[0]['store_district']} ${requestList[0]['store_province']}	',
                  text_align: null,
                  width: width * 0.9,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03, vertical: height * 0.003),
                child: Image.asset(
                  "assets/images/location.png",
                  width: width * 0.04,
                  height: height * 0.02,
                  color: blue,
                ),
              ),
              SizedBox(
                width: width * 0.9,
                height: height * 0.06,
                child: AutoText3(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  fontWeight: null,
                  text:
                      '${requestList[0]['address_detail']} ${requestList[0]['house_number']} ${requestList[0]['county']} ${requestList[0]['district']} ${requestList[0]['province']}',
                  width: width * 0.9,
                  text_align: null,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: width,
            height: height * 0.27,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoText(
                      color: Colors.black,
                      fontSize: 16,
                      text: 'Order Details',
                      text_align: TextAlign.left,
                      width: width * 0.29,
                      fontWeight: FontWeight.bold,
                    ),
                    AutoText(
                      color: requestList[0]['slip_img'] == ''
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 16,
                      text: requestList[0]['slip_img'] == ''
                          ? 'ชำระปลายทาง'
                          : 'QR CODE',
                      text_align: TextAlign.right,
                      width: width * 0.29,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoText(
                      color: Colors.black,
                      fontSize: 16,
                      text: '${requestList[0]['order_id']}',
                      text_align: TextAlign.left,
                      width: width * 0.29,
                      fontWeight: FontWeight.bold,
                    ),
                    AutoText(
                      color: Colors.black,
                      fontSize: 16,
                      text: '${requestList[0]['time']}',
                      text_align: TextAlign.right,
                      width: width * 0.29,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: height * 0.01),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
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
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoText(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      text: 'Subtotal',
                      text_align: null,
                      width: null,
                    ),
                    AutoText(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      text: '${requestList[0]['sum_price']} ฿',
                      text_align: null,
                      width: null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoText(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      text: 'delivery fee',
                      text_align: null,
                      width: null,
                    ),
                    AutoText(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      text: '${requestList[0]['delivery_fee']} ฿',
                      width: null,
                      text_align: null,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        text: '${requestList[0]['total']}฿',
                        text_align: TextAlign.right,
                        width: width * 0.29,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtomSheet2() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.45,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                height: height * 0.011,
                width: width * 0.15,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30)),
              ),
            ],
          ),
          SizedBox(height: height * 0.03),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  barrierColor: Colors.black26,
                  context: this.context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  builder: (context) {
                    return ShowMoDalImg(
                        pickCamera: pickCamera, pickImage: pickImage);
                  });
            },
            child: Container(
              width: width * 0.6,
              height: height * 0.25,
              decoration: BoxDecoration(
                color: Color(0xffdedede),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: image == null
                    ? Container(
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: width * 0.12,
                          ),
                        ),
                      )
                    : Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          buildButtonSendImg()
        ],
      ),
    );
  }

  Widget buildRowText(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoText(
            width: width * 0.3,
            text: '$text1',
            fontSize: 16,
            color: Colors.black,
            text_align: TextAlign.left,
            fontWeight: null,
          ),
          AutoText2(
            width: width * 0.28,
            text: '$text2',
            fontSize: 16,
            color: Colors.black,
            text_align: TextAlign.right,
            fontWeight: null,
          ),
        ],
      ),
    );
  }

  Widget buildButtonSendImg() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      width: width * 0.6,
      height: height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          if (distance! > 0.1) {
            buildShowAlert(context, 'You are not near the customer');
          } else if (image == null) {
            buildShowAlert(context, 'Please Choose Image');
          } else {
            setState(() {
              statusLoading = true;
            });
            success_requst();
          }
        },
        child: Center(
          child: AutoText(
            color: Colors.white,
            fontSize: 16,
            text: 'Send Image',
            text_align: TextAlign.center,
            width: width * 0.29,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
