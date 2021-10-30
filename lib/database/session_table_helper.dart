import 'dart:async';
import 'dart:io';

import 'package:new_field_visit_app/models/SessionSQL.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SessionDBHelper{
  static final _databaseName = 'mydb.db';
  static final _databaseVersion = 1;
  static final _table_sessions = 'sessions';
  static String path;

  SessionDBHelper._privateConstructor();
  static final SessionDBHelper instance = SessionDBHelper._privateConstructor();

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
    await db.execute('CREATE TABLE $_table_sessions(id INTEGER PRIMARY KEY autoincrement, client TEXT, date TEXT, start_address TEXT, description TEXT, end_address TEXT, start_lat DOUBLE, end_lat DOUBLE, start_long DOUBLE, end_long DOUBLE, start_time TEXT,end_time TEXT,purpose TEXT,created_at TEXT,updated_at TEXT)');
  }

  //// Get Datanase file path
  static Future getFileData() async {
    return getDatabasesPath().then((value) {
      return path = value;
    });
  }

  Future insertSession(Session session) async{
    Database db = await instance.database;

    return await db.insert(_table_sessions, Session.toMap(session),conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List <Session>> getSessionList() async {
    Database db = await instance.database;
    List<Map> sessionMaps = await db.query(_table_sessions);
    return Session.fromMapList(sessionMaps);
  }

  Future<Session> updateSession(Session session) async {
    Database db = await instance.database;
    await db.update(_table_sessions, Session.toMap(session), where: 'id = ?', whereArgs: [session.id]);
    return session;
  }

  Future deleteSession(id) async {
    Database db = await instance.database;
    var deleteSession = db.delete(_table_sessions,where: 'id = ?', whereArgs: [id]);
    return deleteSession;
  }

  Future getOfflineSessionCount() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM sessions');
    int count = list.length;
    return count;
  }

}