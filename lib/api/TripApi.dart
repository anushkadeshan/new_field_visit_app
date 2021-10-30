import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:new_field_visit_app/models/trip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripApi{
  String api_base_url = 'https://bdsmis.eastus.cloudapp.azure.com/api/';

  Future getTrips() async
  {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + 'all-trips' + await _getToken();

    final response = await http.get(Uri.parse(fullUrl),
        headers: _setHeaders()
    );

    if(response.statusCode == 201)
    {
      return getTripList(response.body);
    }
    else{
      throw Exception('Unable to fetch data');
    }
  }

  ////////Convert response body -> Trip object list .........
  List<Trip> getTripList(String responseBody)
  {
    final parsedBody = json.decode(responseBody).cast<Map<String , dynamic>>();
    return parsedBody.map<Trip>((json) => Trip.fromJson(json)).toList();
  }

  insertTrip(data, apiUrl) async {
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
  Future tripCounts() async
  {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + 'trip-data' + await _getToken();
    final response = await http.get(Uri.parse(fullUrl),
        headers: _setHeaders()
    );
    if(response.statusCode == 201)
    {
      String filename = 'tripData.json';
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

  Future getSingleTrip(data) async
  {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };

    var fullUrl = api_base_url + 'single-trips' + await _getToken();

    final response = await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data),
        headers: _setHeaders()
    );

    if(response.statusCode == 201)
    {
      return getTripList(response.body);
    }
    else{
      print(response.body);
      throw Exception('Unable to fetch data');
    }
  }

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }
}