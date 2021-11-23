class Session{
  int id;
  String client;
  String date;
  String description;
  String start_address;
  String end_address;
  double start_lat;
  double end_lat;
  double start_long;
  double end_long;
  String start_time;
  String end_time;
  String purpose;
  String image;
  String created_at;
  String updated_at;

  Session({this.id, this.client, this.date, this.description, this.start_address, this.end_address, this.start_lat, this.end_lat, this.start_long, this.end_long, this.start_time, this.end_time, this.created_at, this.updated_at, this.purpose, this.image});
  //////From Map - Query Map => Product Model
  static Session fromMap(Map<String, dynamic> query){
    Session session = Session();
    session.id = query['id'];
    session.client = query['client'];
    session.date = query['date'];
    session.start_address = query['start_address'];
    session.description = query['description'];
    session.end_address = query['end_address'];
    session.start_lat = query['start_lat'];
    session.end_lat = query['end_lat'];
    session.start_long = query['start_long'];
    session.end_long = query['end_long'];
    session.start_time = query['start_time'];
    session.end_time = query['end_time'];
    session.created_at = query['created_at'];
    session.updated_at = query['updated_at'];
    session.purpose = query['purpose'];
    session.image = query['image'];
    return session;
  }

  //////To Map - Query Map => Product  =>  Map
  static Map<String, dynamic> toMap(Session session){
    return <String, dynamic>{
    'id' : session.id,
    'client' : session.client,
    'date' : session.date,
    'start_address' : session.start_address,
    'description' : session.description,
    'end_address' : session.end_address,
    'start_lat' : session.start_lat,
    'end_lat' : session.end_lat,
    'start_long' : session.start_long,
    'end_long' : session.end_long,
    'start_time' : session.start_time,
    'end_time' : session.end_time,
    'created_at' : session.created_at,
    'updated_at' : session.updated_at,
    'purpose' : session.purpose,
      'image' : session.image
    };
  }

  //from map list to list of map
  static List<Session> fromMapList(List<Map<String, dynamic>> query){
    List<Session> sessions = [];
    for(Map<String, dynamic> mp in query){
      sessions.add(fromMap(mp));
    }
    return sessions;
  }
}