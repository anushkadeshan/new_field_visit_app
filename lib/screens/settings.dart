
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_field_visit_app/api/callApi.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _addHome = false;
  bool _addOffice = false;
  bool serviceEnabled = false;
  double lat;
  double long;
  bool homeAdded = false;
  bool officeAdded = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSavedLocationData();

  }

  getSavedLocationData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var homeAdded1 = localStorage.getBool('homeAdded');
    var officeAdded1 = localStorage.getBool('officeAdded');
    if(homeAdded1!= null){
      setState(() {
        homeAdded = homeAdded1;
      });
    }
    print(officeAdded1);
    print(homeAdded1);
    if(officeAdded1!= null){
      setState(() {
        officeAdded = officeAdded1;
      });
    }

  }

  _checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
    // ignore: unrelated_type_equality_checks
    if(permission == LocationPermission.whileInUse || permission ==LocationPermission.always){
      _checkLocationServiceEnabled();
    }

    else{
      _requestLocationPermission();
    }
  }

  _checkLocationServiceEnabled() async {
    bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
    if(isLocationServiceEnabled==true){
      _getCurrentLocation();
      print('location in your phone');
    }
    else{
      serviceEnabled = false;
      print('please enable location in your phone');
    }
  }

  _requestLocationPermission() async{
    LocationPermission permission = await Geolocator.requestPermission();
    // ignore: unrelated_type_equality_checks
    if(permission == LocationPermission.whileInUse ||permission ==LocationPermission.always){
      _checkLocationServiceEnabled();
    }
    else{
      print('you cant use this app bt');
    }
  }

  _getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position==null){

    }
    else{
      lat = position.latitude;
      long = position.longitude;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff4e54c8),
          title: Text('Settings'),
        ),
        body: Container(
          child: SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: 'Home Location',
                    subtitle: _addHome ? 'Please Wait..' : 'Add your home location to the system',
                    leading: Icon(Icons.home),
                    onPressed: (context) async {
                        await _addHomeToSystem();
                    },
                    trailing: homeAdded ? Icon(Icons.where_to_vote,color: Colors.green) : Icon(Icons.add_box,color: Colors.blue,),
                  ),

                  SettingsTile(
                    title: 'Office Location',
                    subtitle: _addOffice ? 'Please Wait..' :'Add your office location to the system',
                    leading: Icon(Icons.work),
                      onPressed: (context) async{
                        await _addOfficeToSystem();
                      },
                    trailing: officeAdded ? Icon(Icons.where_to_vote,color: Colors.green) : Icon(Icons.add_box,color: Colors.blue,),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Account',
                tiles: [
                  SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

   _addHomeToSystem() async {
     getSavedLocationData();
     setState(() {
      _addHome = true;
    });
    await _checkLocationPermission();
    var data = {
      'home_lattitudes' : lat,
      'home_longitudes' : long
    };
    var response = await CallApi().addHome(data, 'add-home');
    var body = json.decode(response.body);
    print(body);
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setBool('homeAdded', true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'],textAlign: TextAlign.center,),
          backgroundColor: Colors.green,
        ),
      );
    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'],textAlign: TextAlign.center,),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _addHome = false;
    });
  }

  _addOfficeToSystem() async {
    getSavedLocationData();
    setState(() {
      _addOffice = true;
    });
    await _checkLocationPermission();
    var data = {
      'office_lattitudes' : lat,
      'office_longitudes' : long
    };
    var response = await CallApi().addOffice(data, 'add-office');
    var body = json.decode(response.body);
    print(body);
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setBool('officeAdded', true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'],textAlign: TextAlign.center,),
          backgroundColor: Colors.green,
        ),
      );
    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'],textAlign: TextAlign.center,),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _addOffice = false;
    });
  }
}
