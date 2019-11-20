class LocationInfo{
  String id ;
  String  deviceId;
  String latitude;
  String longitude;
  String time;

  LocationInfo( {this.id,this.deviceId,this.latitude,this.longitude,this.time});

  final List<LocationInfo> availableLocations = [
    LocationInfo(
      id:'1',
      deviceId: 'Nokia2',
      latitude: '27.6609',
      longitude: ' 83.4660983',
      time: '125689'
    ),
        LocationInfo(
      id:'12',
      deviceId: 'Samsung ',
      latitude: '27.6609',
      longitude: '83.4661',
      time: '125689'
    ),
        LocationInfo(
      id:'1',
      deviceId: 'OPPo',
      latitude: '40.235',
      longitude: '83.4661',
      time: '125689'
    ),
  ];

}