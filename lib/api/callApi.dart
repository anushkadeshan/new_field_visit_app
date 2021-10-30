import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_field_visit_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallApi extends ChangeNotifier{
  final String _url = 'https://bdsmis.eastus.cloudapp.azure.com/api/';

  bool _isLoggedIn = false;
  User _user;
  String _token;

  bool get authenticated => _isLoggedIn;
  User get user => _user;

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl + await _getToken();
    var response =  await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
    var body = json.decode(response.body);
    if(body['success']){
      this._user = User.fromJson(body['user']);
    }
    notifyListeners();
    return response;
  }
  getData(apiUrl) async {
    var fullUrl = _url + apiUrl + await _getToken();
    //print(fullUrl);
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
  };

  logOut(apiUrl, token) async {
    var fullUrl = _url + apiUrl + await _getToken();
    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );
  }

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }
}