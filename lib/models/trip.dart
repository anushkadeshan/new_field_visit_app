class Trip {
  int id;
  String date;
  String start_meter_reading;
  String trip_id;
  double latitude;
  double longitude;
  dynamic accuracy;
  dynamic altitude;
  dynamic speed;
  String end_meter_reading;
  dynamic time;
  dynamic distance;
  String end_time;
  String start_time;


  Trip({this.id, this.start_meter_reading, this.trip_id, this.latitude, this.longitude, this.accuracy, this.altitude, this.speed, this.end_meter_reading, this.time, this.date, this.distance,this.start_time,this.end_time});

  Trip.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start_meter_reading = json['start_meter_reading'];
    trip_id = json['trip_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    accuracy = json['accuracy'];
    altitude = json['altitude'];
    speed = json['speed'];
    end_meter_reading = json['end_meter_reading'];
    time = json['time'];
    date = json['date'];
    distance = json['distance'];
    end_time = json['end_time'];
    start_time = json['start_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_meter_reading'] = this.start_meter_reading;
    data['trip_id'] = this.trip_id;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['accuracy'] = this.accuracy;
    data['altitude'] = this.altitude;
    data['speed'] = this.speed;
    data['end_meter_reading'] = this.end_meter_reading;
    data['time'] = this.time;
    data['date'] = this.date;
    data['distance'] = this.distance;
    data['start_time'] = this.start_time;
    data['end_time'] = this.end_time;

    return data;
  }
}