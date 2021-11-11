class Trip{
  int id;
  String start_meter_reading;
  String trip_start_location;
  String trip_end_location;
  String start_time;
  String end_time;
  String date;
  String trip_id;
  double latitude;
  double longitude;
  double accuracy;
  double altitude;
  double speed;
  String end_meter_reading;
  double time;

  Trip({this.id, this.start_meter_reading, this.trip_start_location, this.trip_end_location, this.trip_id, this.latitude, this.longitude, this.accuracy, this.altitude, this.speed, this.end_meter_reading, this.time,this.start_time,this.date,this.end_time});
  //////From Map - Query Map => Product Model
  static Trip fromMap(Map<String, dynamic> query){
    Trip trip = Trip();
    trip.id = query['id'];
    trip.start_meter_reading = query['start_meter_reading'];
    trip.trip_start_location = query['trip_start_location'];
    trip.trip_end_location = query['trip_end_location'];
    trip.trip_id = query['trip_id'];
    trip.latitude = query['latitude'];
    trip.longitude = query['longitude'];
    trip.accuracy = query['accuracy'];
    trip.altitude = query['altitude'];
    trip.speed = query['speed'];
    trip.time = query['time'];
    trip.end_meter_reading = query['end_meter_reading'];
    trip.start_time = query['start_time'];
    trip.date = query['date'];
    trip.end_time = query['end_time'];
    return trip;
  }

  //////To Map - Query Map => Product  =>  Map
  static Map<String, dynamic> toMap(Trip trip){
    return <String, dynamic>{
      'id' : trip.id,
      'start_meter_reading' :trip.start_meter_reading,
      'trip_start_location' :trip.trip_start_location,
      'trip_end_location' : trip.trip_end_location,
      'trip_id' : trip.trip_id,
      'latitude' : trip.latitude,
      'longitude' : trip.longitude,
      'accuracy' : trip.accuracy,
      'altitude' : trip.altitude,
      'speed' : trip.speed,
      'end_meter_reading' : trip.end_meter_reading,
      'time' : trip.time,
      'start_time' : trip.start_time,
      'date' : trip.date,
      'end_time' : trip.end_time,
    };
  }

  //from map list to list of map
  static List<Trip> fromMapList(List<Map<String, dynamic>> query){
    List<Trip> trips = [];
    for(Map<String, dynamic> mp in query){
      trips.add(fromMap(mp));
    }
    return trips;
  }
}