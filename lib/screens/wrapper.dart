import 'package:flutter/material.dart';
import 'package:new_field_visit_app/auth_provider/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    // TODO: implement initState
    _checkToken();
    super.initState();
  }

  _checkToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    Provider.of<Auth>(context, listen: false).tryToken(token: token);
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
