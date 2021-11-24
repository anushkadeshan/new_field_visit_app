import 'dart:async';
import 'dart:io';

import 'package:new_field_visit_app/models/TripSQL.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TripDBHelper{
  static final _databaseName = 'field_trips_new1.db';
  static final _databaseVersion = 6;
  static final _table_trips = 'tripsNewTable';
  static String path;

  TripDBHelper._privateConstructor();
  static final TripDBHelper instance = TripDBHelper._privateConstructor();

  static Database _database;

  Future get database async{
    if(_database != null) return _database;
    _database = await _initDatabase();

    return _database;
  }

  ////// initialize database to your local storage file path with give db name
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate
    );
  }
  ///////on create method for creating datanase with table name and column names
  FutureOr<void> _onCreate(Database db, int version) async{
    await db.execute('CREATE TABLE $_table_trips(id INTEGER PRIMARY KEY autoincrement, start_meter_reading TEXT, trip_start_location TEXT, trip_end_location TEXT, trip_id TEXT, latitude DOUBLE, longitude DOUBLE, accuracy DOUBLE, altitude DOUBLE, speed DOUBLE, end_meter_reading TEXT, time DOUBLE, end_time TEXT, date TEXT, start_time TEXT)');
  }

  //// Get Database file path
  static Future getFileData() async {
    return getDatabasesPath().then((value) {
      return path = value;
    });
  }

  Future insertTrip(Trip trip) async{
    Database db = await instance.database;

    return await db.insert(_table_trips, Trip.toMap(trip),conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List <Trip>> getTripList() async {
    Database db = await instance.database;
    List<Map> tripMaps = await db.query(_table_trips, orderBy: "time", groupBy: "trip_id");
    return Trip.fromMapList(tripMaps);
  }

  Future<List <Trip>> getTripListForDistance(tripId) async {
    Database db = await instance.database;
    List<Map> tripMaps = await db.query(_table_trips, where: 'trip_id = ?', whereArgs: [tripId]);
    return Trip.fromMapList(tripMaps);
  }

  Future<Trip> updateTrip(Trip trip) async {
    Database db = await instance.database;
    await db.update(_table_trips, Trip.toMap(trip), where: 'trip_id = ?', whereArgs: [trip.trip_id]);
    return trip;
  }

  Future<int> updateTrip2(end_meter_reading, trip_id, end_time, trip_stop_location) async {
    Database db = await instance.database;
    final result =  await   db.rawUpdate('UPDATE tripsNewTable SET end_meter_reading = ?, end_time = ? , trip_end_location = ?  WHERE trip_id = ? ', [end_meter_reading,end_time,trip_stop_location,trip_id,]);
    return result;
  }

  Future deleteTrip(Trip trip) async {
    Database db = await instance.database;
    var deleteTrip = db.delete(_table_trips,where: 'id = ?', whereArgs: [trip.id]);
    return deleteTrip;
  }

  Future getOfflineTripCount() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM tripsNewTable GROUP BY trip_id');
    int count = list.length;
    print(count);
    return count;
  }

  Future<List <Trip>> viewTrip(tripId) async {
    Database db = await instance.database;
    List<Map> tripMaps = await db.query(_table_trips, where: 'trip_id = ?', whereArgs: [tripId]);
    return Trip.fromMapList(tripMaps);
  }

}