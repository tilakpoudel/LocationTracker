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

import './views/mapView.dart';

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
  bool sentData = false;
  bool trackMe = false;

  List<Marker> allMarkers = [];

  get availableLocations => null;

  @override
  void initState() {
    super.initState();
    getInitialLocation();
    getAllLocation();
    // availableLocations.forEach((element) {
      allMarkers.add(Marker(
          markerId: MarkerId('1'),
          draggable: false,
          infoWindow:
              InfoWindow(title: 'Test', snippet: 'Test device'),
          position: LatLng(27.833, 83.564),
          icon: BitmapDescriptor.defaultMarker,
          )
          );
    // });
  }

  void getInitialLocation() async {
    var geolocator = Geolocator();
    Position initialPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    pushLocation(initialPosition);
    // print(initialPosition);
  }

  void getCurrentLocation(bool toggleLocation) {
    userLocation = [];
    var geolocator = Geolocator();
    if (toggleLocation) {
      print(toggleLocation);
      print("pushing..");
      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 1);
      try {
        geolocator
            .getPositionStream(locationOptions)
            .listen((Position position) async {

          print(position);
          pushLocation(position);
          setState(() {
            currentLocation = position;
            mapToggle = true;
            trackMe = toggleLocation;
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
    } else {
      setState(() {
        trackMe = toggleLocation;
        Alert(
          context: context,
          type: AlertType.warning,
          title: "Turn On LOcation ",
          desc: "Failed to push ",
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
  }

  void pushLocation(Position position) async {
    print('pushing location $position');
    var url = 'http://www.itandrc.com/NepathyaRestApi/api/location';
    // var url = 'https://location-tracker-bd639.firebaseio.com/locations.json';
    final token = "NEPATHYATILAK";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      // HttpHeaders.authorizationHeader: "Bearer $token",//if there is token required for the api
      'AUTH_KEY': token,//if there is token required for the api

    };
    DateTime now = DateTime.now();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    print('Running on device ${androidInfo.androidId}');

    var body = json.encode({
      'device_id': androidInfo.androidId.toString(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'time': now.toString()
    });
    try {
      var response = await http.post(url, headers: headers, body: body);
      var lastlocation = json.decode(response.body);
      var responseCode = response.statusCode;
      if (responseCode == 200 || responseCode ==201) {
        setState(() {
          sentData = true;
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
      } else {
        setState(() {
          sentData = false;
          Alert(
            context: context,
            type: AlertType.error,
            title: "Location Pushed To Server ?",
            desc: "Failed to push ",
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
      // print('Response body: $lastlocation');
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  void getAllLocation() async {
    var url = 'http://www.itandrc.com/NepathyaRestApi/api/location';

    // var url = 'https://location-tracker-bd639.firebaseio.com/locations.json';
    // FirebaseApp.initializeApp(this);

    try {
      // DatabaseReference locRef =
      //     FirebaseDatabase.instance.reference().child("locations");
      // locRef.once().then((DataSnapshot snap) {
      //   var keys = snap.value.keys;
      //   var data = snap.value;
      //   // print(data.runtimeType);

      //   userLocation.clear();
      //   for (var individualKey in keys) {
      //     LocationInfo locationInfo = new LocationInfo(
      //       id: individualKey.toString(),
      //       deviceId: data[individualKey]['device_id'].toString(),
      //       latitude: data[individualKey]['latitude'].toString(),
      //       longitude: data[individualKey]['longitude'].toString(),
      //       time: data[individualKey]['time'].toString(),
      //     );
      //     userLocation.add(locationInfo);
      //     // print(data[individualKey]['device_id'].toString());
      //     // print(locationInfo.deviceId);

      //   }
      //   // print(userLocation);
      // });

      final response = await http.get(url,headers: {'AUTH_KEY':'NEPATHYATILAK'});
      final extractedData = json.decode(response.body) as Map<String,dynamic>;
      List<LocationInfo> loadedLocation = [];
      extractedData.forEach((locationId,locationData){
        // print(locationData['device_id']);
        loadedLocation.add(LocationInfo(
          id:locationId,
          deviceId: locationData['device_id'].toString(),
          latitude:locationData['latitude'].toString(),
          longitude:locationData['longitude'].toString(),
          time:locationData['time'].toString(),
        ));
      });
      userLocation = loadedLocation;
      print(loadedLocation.length);
      //  print(extractedData);

    } catch (e) {
      print(e);
      // throw(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Location"),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Location",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              Switch(
                value: trackMe,
                onChanged: (value) {
                  getCurrentLocation(value);
                },
              ),
            ],
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
                          myLocationEnabled: true,
                          markers: Set.from(allMarkers),
                          // markers: Set<Marker>.of(
                          //     markers.values), // YOUR MARKS IN MAP
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
      ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
