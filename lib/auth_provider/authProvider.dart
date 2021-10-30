import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_field_visit_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  final String _url = 'https://bdsmis.eastus.cloudapp.azure.com/api/';
  bool _isLoggedIn = false;
  bool _isLoggedInOffline = false;
  User _user;
  String _token;

  bool get authenticated => _isLoggedIn;
  bool get offline => _isLoggedInOffline;
  User get user => _user;

  void tryTokenOffline({String token}) async {
    if (token == null) {
      return;
    } else {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var user = localStorage.getString('user');
      this._isLoggedIn = true;
      this._user = User.fromJson(jsonDecode(user));
      this._isLoggedInOffline = true;
      this._token = token;
      notifyListeners();
    }
  }
  void tryToken({String token}) async {
    _setHeaders() => {
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (token == null) {
      return;
    } else {
      try {
        var fullUrl = _url + 'user' ;
        var response =  await http.get(
            fullUrl,
            headers: _setHeaders()
        );
        var body =  json.decode(response.body);
        this._isLoggedIn = true;
        this._user = User.fromJson(body['user']);
        this._token = token;
        notifyListeners();

      } catch (e) {
        print(e);
      }
    }
  }
}