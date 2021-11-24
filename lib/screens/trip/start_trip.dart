import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:new_field_visit_app/screens/trip/trip_running.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartTrip extends StatefulWidget {

  @override
  _StartTripState createState() => _StartTripState();
}

class _StartTripState extends State<StartTrip> {
  final Location location = Location();
  PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  bool _backGroundServiceEnabled;
  String _error;
  bool is_loading = false;
  bool _is_saving = false;
  bool _other_field = false;

  LocationData _location;

  double start_lat;
  double start_long;
  String start_address  = '';

  final _formKey = GlobalKey<FormState>();
  String _start_meter_reading = '';
  String _trip_start_location = '';

  final List<String> _locations = [
    'Office',
    'Home',
    'Other',
  ];

  void initState() {
    // TODO: implement initState
    is_loading=true;
    super.initState();
    _checkTripStatus();
    _checkPermissions();
    _requestPermission();
    _checkService();
    _checkBackgroundMode();
    _getLocation();

    is_loading =false;
  }

  _checkTripStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var tripRunning = localStorage.getBool('tripRunning');
    print(tripRunning);
    if(tripRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please End the current trip before start a new',textAlign: TextAlign.center,),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => TripRunning()));
    }
  }

  Future<void> _checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
    await location.hasPermission();
    print("1");
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
      await location.requestPermission();
      print("2");
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
    }
  }

  Future<void> _checkService() async {
    final bool serviceEnabledResult = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabledResult;
    });
    if(!_serviceEnabled){
      await _requestService();
    }
  }

  Future<void> _requestService() async {
    if (_serviceEnabled == true) {
      return;
    }
    final bool serviceRequestedResult = await location.requestService();
    setState(() {
      _serviceEnabled = serviceRequestedResult;
    });
  }

  Future<void> _checkBackgroundMode() async {
    setState(() {
      _error = null;
    });
    final bool result = await location.isBackgroundModeEnabled();
    setState(() {
      _backGroundServiceEnabled = result;
    });
    if(!_backGroundServiceEnabled){
      await _toggleBackgroundMode();
    }
  }

  Future<void> _toggleBackgroundMode() async {
    setState(() {
      _error = null;
    });
    try {
      final bool result =
      await location.enableBackgroundMode(enable: !(_backGroundServiceEnabled ?? false));
      setState(() {
        _backGroundServiceEnabled = result;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  Future<void> _getLocation() async {
    location.enableBackgroundMode(enable: true);
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
        start_long = _location.longitude;
        start_lat = _location.latitude;
      });
      await _getAddress(start_lat, start_long);
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  _getAddress(lat,long) async{
    try{
      final coordinates = new Coordinates(lat, long);
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final first = addresses.first;
      setState(() {
        is_loading = false;
        start_address = "${first.addressLine}";
      });
    }
    catch(e){
      setState(() {
        is_loading = false;
        start_address = "";
      });
    }
  }

  Widget build(BuildContext context) {
    if(!is_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff4e54c8),
          centerTitle: true,
          title: Text('Initial Trip Data'),
          actions: <Widget>[
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                children:  <Widget>[
                  SizedBox(height: 20.0),
                  Center(child: Text('Add Below data before start the Session',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),)),
                  SizedBox(height: 40.0,),
                  TextFormField(
                    autofocus: true,
                    cursorColor: Colors.purpleAccent,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.purpleAccent),
                    validator: (val) =>
                      val.isEmpty ? 'Enter Start Meter Reading' : null,
                    onChanged: (val) {
                      setState(() => _start_meter_reading = val);
                    },
                    decoration: new InputDecoration(
                      errorStyle: TextStyle(color: Colors.red[200]),
                      prefixIcon: Icon(
                        Icons.av_timer_rounded,
                        color: Colors.purpleAccent,
                      ),
                      labelText: "Current Meter Reading",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        borderSide: new BorderSide(
                        ),
                      ),
                      //fillColor: Colors.green
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  DropdownButtonFormField(
                    isExpanded: true,
                    style: TextStyle(color: Colors.purpleAccent, fontSize: 15.0),
                    decoration: new InputDecoration(
                      errorStyle: TextStyle(color: Colors.red[200]),
                      prefixIcon: Icon(
                        Icons.directions_car,
                        color: Colors.purpleAccent,
                      ),
                      labelText: "Trip Start Location",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        borderSide: new BorderSide(
                        ),
                      ),
                      //fillColor: Colors.green
                    ),
                    items: _locations.map((String myPurpose) {
                      return DropdownMenuItem(
                        value: myPurpose,
                        child: Text('$myPurpose'),
                      );
                    }).toList(),
                    validator: (val) => val ==null ? 'Select Trip Start Location' : null,
                    onChanged: (val) {
                      if(val=='Other'){
                        setState(() => _other_field = true);
                      }
                      else{
                        _other_field = false;
                        setState(() => _trip_start_location = val);
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  _other_field == true ?
                  TextFormField(
                    autofocus: true,
                    cursorColor: Colors.purpleAccent,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.purpleAccent),
                    validator: (val) => val.isEmpty ? 'This field is required' : null,
                    onChanged: (val) {
                      setState(() => _trip_start_location = val);
                    },
                    decoration: new InputDecoration(
                      errorStyle: TextStyle(color: Colors.red[200]),
                      prefixIcon: Icon(
                        Icons.directions_car,
                        color: Colors.purpleAccent,
                      ),
                      labelText: "Specify Location",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        borderSide: new BorderSide(
                        ),
                      ),
                      //fillColor: Colors.green
                    ),
                  ) : SizedBox(height: 1.0),
                  SizedBox(height: 20,),
                  InkWell(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Color(0xff4e54c8),
                                Color.fromRGBO(143, 148, 251, 1),
                              ]
                          )
                      ),
                      child: Center(
                        child: Text(
                          _is_saving ? "Please Wait..." : 'Start the Trip' ,
                          style: TextStyle(color: Colors.white, fontSize: 20),),
                      ),
                    ),
                    onTap: () async {
                      if(_formKey.currentState.validate()){
                        FocusScope.of(context).requestFocus(FocusNode());
                        _is_saving ? null :
                        _is_saving = true;
                        SharedPreferences localStorage = await SharedPreferences.getInstance();
                        localStorage.setString('start_meter_reading', _start_meter_reading);
                        localStorage.setString('trip_start_location', _trip_start_location);
                        localStorage.setString('start_time', DateFormat('hh:mm:ss').format(DateTime.now()));
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => TripRunning()
                          ),
                        );
                        _is_saving = false;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    else{
      return Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: SpinKitFadingCube(
            color: Color(0xff4e54c8),
            size: 40.0,
          ),
        ),
      );
    }
  }
}
