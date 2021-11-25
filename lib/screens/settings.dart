
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
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
  bool _addBoarding = false;
  bool serviceEnabled = false;
  double lat;
  double long;
  bool homeAdded = false;
  bool officeAdded = false;

  String start_address ='';
  String homeAddress ='';
  String officeAddress ='';
  bool boardingHouse = false;
  String bikePlate = '';
  final _formKey = GlobalKey<FormState>();


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
    var boardingHouse1 = localStorage.getBool('boardingHouse');
    var officeAddress1 = localStorage.getString('officeAddress');
    var homeAddress1 = localStorage.getString('homeAddress');
    if(homeAdded1!= null){
      setState(() {
        homeAdded = homeAdded1;
        officeAddress = officeAddress1;
        homeAddress = homeAddress1;
        boardingHouse = boardingHouse1;
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
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });

      await _getAddress(lat, long);
    }
  }

  _getAddress(lat,long) async{
    try{
      final coordinates = new Coordinates(lat, long);
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final first = addresses.first;
      setState(() {
        start_address = "${first.addressLine}";
      });

    }
    catch(e){
      setState(() {
        start_address = "";
      });
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
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SettingsList(
            sections: [
              SettingsSection(
                title: 'Location',
                tiles: [
                  SettingsTile(
                    title: 'Home/Boarding Location',
                    subtitle: _addHome ? 'Please Wait..' : homeAddress != '' ? homeAddress :  'Add your home location to the system',
                    leading: Icon(Icons.home),
                    onPressed: (context) async {
                        await _addHomeToSystem();
                    },
                    trailing: homeAdded ? Icon(Icons.where_to_vote,color: Colors.green) : Icon(Icons.add_box,color: Colors.blue,),
                  ),

                  SettingsTile(
                    title: 'Office Location',
                    subtitle: _addOffice ? 'Please Wait..' : officeAddress != '' ? officeAddress : 'Add your office location to the system',
                    leading: Icon(Icons.work),
                      onPressed: (context) async{
                        await _addOfficeToSystem();
                      },
                    trailing: officeAdded ? Icon(Icons.where_to_vote,color: Colors.green) : Icon(Icons.add_box,color: Colors.blue,),
                  ),
                  SettingsTile.switchTile(
                    title: 'I am in a Boarding House',
                    subtitle: _addBoarding ? 'Please Wait..' : 'if you are in your own home, do not change',
                    leading: Icon(Icons.fingerprint),
                    onToggle: (bool value) async{
                      setState(() {
                        boardingHouse = value;
                      });
                      await _addBoardingHouse(value);
                    },
                    switchValue: boardingHouse,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Account',
                tiles: [
                  SettingsTile(
                      title: 'Bike Plate',
                      subtitle: bikePlate =='' ? 'Enter your Bike Plate Number' : bikePlate,
                      leading: Icon(Icons.motorcycle),
                      trailing: Icon(Icons.arrow_forward_rounded),

                    onPressed: (context) => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Add Bike Plate Number'),
                        content:
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: Colors.purpleAccent,
                            initialValue: bikePlate,
                            style: TextStyle(color: Colors.purpleAccent),
                            validator: (val) => val.isEmpty ? 'Enter Bike Plate No' : null,
                            onChanged: (val) {
                              setState(() => bikePlate = val);
                            },
                            decoration: new InputDecoration(
                              errorStyle: TextStyle(color: Colors.red[200]),
                              prefixIcon: Icon(
                                Icons.motorcycle,
                                color: Colors.purpleAccent,
                              ),
                              labelText: "Bike Plate Number",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                borderSide: new BorderSide(
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async{
                              var data = {
                                'bike_number' : bikePlate,
                              };

                              var response = await CallApi().addHome(data, 'add-bike');
                              var body = json.decode(response.body);
                              if(body['success']){
                                SharedPreferences localStorage = await SharedPreferences.getInstance();
                                localStorage.setString('bikePlate',bikePlate);
                                await getSavedLocationData();
                                Navigator.pop(context, 'Cancel');
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
                            }
                            ,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setBool('homeAdded', true);
      localStorage.setString('homeAddress',start_address);
      await getSavedLocationData();

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
      localStorage.setString('officeAddress',start_address);
      await getSavedLocationData();
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

  _addBoardingHouse(value) async {
    setState(() {
      _addBoarding = true;
    });
    getSavedLocationData();
    var data = {
      'is_boarded' : value,
    };
    var response = await CallApi().addBoarding(data, 'add-boarding');
    var body = json.decode(response.body);
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setBool('boardingHouse', value);
      await getSavedLocationData();
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
      _addBoarding = false;
    });
  }
}
