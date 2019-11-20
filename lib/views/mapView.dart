import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class MapView extends StatefulWidget {

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
    GoogleMapController mapController;
    var currentLocation;
    bool mapToggle;
    void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
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
        );
  }
}