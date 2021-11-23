class Session {
  dynamic id;
  String client;
  String date;
  String description;
  String start_address;
  String end_address;
  dynamic start_lat;
  dynamic end_lat;
  dynamic start_long;
  dynamic end_long;
  String start_time;
  String end_time;
  String purpose;
  String image;
  String created_at;
  String updated_at;
  String user_id;


  Session({this.id, this.client, this.date, this.description, this.start_address, this.end_address, this.start_lat, this.end_lat, this.start_long, this.end_long, this.start_time, this.end_time, this.created_at, this.updated_at, this.user_id, this.purpose, this.image});

  Session.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    client = json['client'];
    date = json['date'];
    start_address = json['start_address'];
    description = json['description'];
    end_address = json['end_address'];
    start_lat = json['start_lat'];
    end_lat = json['end_lat'];
    start_long = json['start_long'];
    end_long = json['end_long'];
    start_time = json['start_time'];
    end_time = json['end_time'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    user_id = json['user_id'];
    purpose = json['purpose'];
    image = json['image'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client'] = this.client;
    data['date'] = this.date;
    data['description'] = this.description;
    data['start_address'] = this.start_address;
    data['end_address'] = this.end_address;
    data['start_lat'] = this.start_lat;
    data['end_lat'] = this.end_lat;
    data['start_long'] = this.start_long;
    data['end_long'] = this.end_long;
    data['start_time'] = this.start_time;
    data['end_time'] = this.end_time;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    data['user_id'] = this.user_id;
    data['purpose'] = this.purpose;
    data['image'] = this.image;

    return data;
  }
}