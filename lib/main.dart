import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import './location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double appBarHeight = AppBar().preferredSize.height;
  bool mapToggle = false;
  var currentLocation;
  List<LocationInfo> userLocation = [];

  GoogleMapController mapController;
  Marker marker;
  bool sent_data = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() {
    userLocation = [];
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.best, distanceFilter:5);
    try {
      geolocator
          .getPositionStream(locationOptions)
          .listen((Position position) async {
        // userLocation.add(position);
        // print('data in list $userLocation');
        // addMarker(position);
        pushLocation(position);
        setState(() {
          currentLocation = position;
          mapToggle = true;
        });
        print(position == null
            ? 'Unknown'
            : "current location is ${position.latitude.toString()}" +
                ', ' +
                position.longitude.toString());
      });
    } catch (e) {
      print(e);
    }
  }

  void pushLocation(Position position) async {
    print(position);
    var url = 'https://location-tracker-bd639.firebaseio.com/locations.json';
    // final token = "NEPATHYATILAK";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      // HttpHeaders.authorizationHeader: "Bearer $token",//if there is token required for the api
    };
    DateTime now = DateTime.now();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    print('Running on ${androidInfo.androidId}');

    var body = json.encode({
      'device_id': androidInfo.androidId.toString(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'time': now.toString()
    });
    try {
      var response = await http.post(url, headers: headers, body: body);
      var lastlocation = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          sent_data = true;
          Alert(
            context: context,
            type: AlertType.success,
            title: "Location Pushed To Server",
            desc: "Succesfully pushed to server.",
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        });
      }
      print('Response status: ${response.statusCode}');
      print('Response body: $lastlocation');
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  void getAllLocation() async {
    // var url = 'https://location-tracker-bd639.firebaseio.com/locations.json';
    // FirebaseApp.initializeApp(this);

    try {
      DatabaseReference locRef =
          FirebaseDatabase.instance.reference().child("locations");
      locRef.once().then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        // print(data.runtimeType);

        userLocation.clear();
        for (var individualKey in keys) {
          LocationInfo locationInfo = new LocationInfo(
            individualKey.toString(),
            data[individualKey]['device_id'].toString(),
            data[individualKey]['latitude'].toString(),
            data[individualKey]['longitude'].toString(),
            data[individualKey]['time'].toString(),
          );
          userLocation.add(locationInfo);
          // print(data[individualKey]['device_id'].toString());
          // print(locationInfo.deviceId);

        }
        // print(userLocation);
      });

      // final response = await http.get(url);
      // final extractedData = json.decode(response.body) as Map<String,dynamic>;
      // List<LocationInfo> loadedLocation = [];
      // extractedData.forEach((locationId,locationData){
      //   // print(locationData['device_id']);
      //   loadedLocation.add(LocationInfo(
      //     locationId,
      //     locationData['device_id'].toString(),
      //     locationData['latitude'].toString(),
      //     locationData['longitude'].toString(),
      //     locationData['time'].toString(),
      //   ));
      // });
      // userLocation = loadedLocation;
      // print(loadedLocation);

    } catch (e) {
      print(e);
      // throw(e);
    }
    // print(userLocation);
  }

  // void addMarker(position){
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // MarkerId selectedMarker;

  // setState(() {
  //       markers[selectedMarker] = marker;
  // });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Track Location"),
          actions: <Widget>[
            FlatButton(
              child: Text("My Location"),
              onPressed: () => getCurrentLocation(),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height - 80.0,
                    width: double.infinity,
                    child: mapToggle
                        ? GoogleMap(
                            onMapCreated: onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(currentLocation.latitude,
                                  currentLocation.longitude),
                              zoom: 18,
                              tilt: 30.0,
                            ),
                            mapType: MapType.normal,
                            compassEnabled: true,
                            myLocationButtonEnabled: true,
                            // markers: Set<Marker>.of(currentLocation),
                          )
                        // Text("Your location is ${currentLocation.latitude} ${currentLocation.longitude}"):

                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          )),
              ],
            ),
          ],
        ));
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
