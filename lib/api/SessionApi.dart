import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:new_field_visit_app/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SessionApi{
  String api_base_url = 'https://bdsmis.eastus.cloudapp.azure.com/api/';

  Future<List<Session>> getSessions() async
  {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };
    var fullUrl = api_base_url + 'all-sessions' + await _getToken();
    final response = await http.get(Uri.parse(fullUrl),
      headers: _setHeaders()
    );

    //print(response.body);

    if(response.statusCode == 201)
    {
      return getSessionList(response.body);
    }
    else{
      print(response.body);
      throw Exception('Unable to fetch data');
    }
  }

  ////////Convert response body -> Session object list .........
  List<Session> getSessionList(String responseBody)
  {
    final parsedBody = json.decode(responseBody).cast<Map<String , dynamic>>();
    return parsedBody.map<Session>((json) => Session.fromJson(json)).toList();
  }

  insertSession(data, apiUrl) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + apiUrl + await _getToken();
    var response =  await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
    var body = json.decode(response.body);
    return response;
  }
  //get this week session count
  Future sessionCounts() async
  {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + 'sessions-counts' + await _getToken();
    final response = await http.get(Uri.parse(fullUrl),
        headers: _setHeaders()
    );
    if(response.statusCode == 201)
    {
      String filename = 'sessionsCounts.json';
      var dir = await getTemporaryDirectory();
      File file =  File(dir.path + "/" + filename);
      file.writeAsStringSync(response.body, flush: true,mode: FileMode.write);
      final res = json.decode(response.body);
      return res;
    }
    else{

      print(response.body);
      throw Exception('Unable to fetch data');
    }
  }

  updateSession(data) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + 'update-session' + await _getToken();
    var response =  await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
    var body = json.decode(response.body);
    return body;
  }

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }

}