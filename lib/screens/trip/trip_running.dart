import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:new_field_visit_app/database/trip_table_helper.dart';
import 'package:new_field_visit_app/models/TripSQL.dart';
import 'package:new_field_visit_app/screens/session/time_provider.dart';
import 'package:new_field_visit_app/screens/trip/trip_success.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TripRunning extends StatefulWidget {
  @override
  _TripRunningState createState() => _TripRunningState();
}

class _TripRunningState extends State<TripRunning> {

  final Location location = Location();
  var timer;
  bool _is_saving = false;
  bool _serviceEnabled = false;
  String _error = '';
  String tripId;

  LocationData _location;

  StreamSubscription<LocationData> _locationSubscription;
  final _formKey = GlobalKey<FormState>();
  String end_meter_reading = '';
  String trip_stop_location = '';
  String start_time = '';
  String start_meter_reading = '';
  String trip_start_location = '';


  void initState() {
    // TODO: implement initState
    super.initState();
    _initiateSettings();
    _generateTripId();
    setTripStatus();

    timer = Provider.of<TimerProvider>(context, listen: false);
    timer.startTimer();
    //print(_locationSubscription);
  }
  _generateTripId() async {
    var uuid =  await Uuid();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var trip_start_location1 = localStorage.getString('trip_start_location');
    var start_meter_reading1 = localStorage.getString('start_meter_reading');
    var start_time1 = localStorage.getString('start_time');
    // Generate a v1 (time-based) id
    setState(() {
      start_time = start_time1;
      start_meter_reading = start_meter_reading1;
      trip_start_location = trip_start_location1;
      tripId = uuid.v1();
    });
  }

  setTripStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setBool('tripRunning', true);
  }
  Future<void> _initiateSettings() async {
    final result = await location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 5000,
      distanceFilter: double.parse('0'),
    );
    print(result);
    if(result){
      _listenLocation();
    }
  }

  Future _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
          if (err is PlatformException) {
            setState(() {
              _error = err.code;
            });
            print("error");
          }
          _locationSubscription.cancel();
          setState(() {
            _locationSubscription = null;
          });
        }).listen((LocationData currentLocation) async {
          setState(() {
            _error = null;
            _location = currentLocation;
          });
          Trip trip = Trip(
            trip_id : tripId,
            start_time: start_time,
            date :  DateFormat('yyyy-MM-dd').format(DateTime.now()),
            start_meter_reading : start_meter_reading,
            trip_start_location : trip_start_location,
            latitude : _location.latitude,
            longitude : _location.longitude,
            accuracy : _location.accuracy,
            altitude : _location.altitude,
            speed : _location.speed,
            time : _location.time,
          );

          await TripDBHelper.instance.insertTrip(trip).then((value) {
            if(value!= null){
              setState(() {
                print('save done');
              });
            }
            else{

            }
          });


        });
    setState(() {});
  }

  //Future<void> _checkService() async {
  //  final bool serviceEnabledResult = await location.serviceEnabled();
  //  print("3");
  //  setState(() {
  //    _serviceEnabled = serviceEnabledResult;
  //  });
  //  if(!_serviceEnabled){
  //    await _requestService();
  //  }
  //}
//
  //Future<void> _requestService() async {
  //  if (_serviceEnabled == true) {
  //    return;
  //  }
  //  print("4");
  //  final bool serviceRequestedResult = await location.requestService();
  //  setState(() {
  //    _serviceEnabled = serviceRequestedResult;
  //  });
  //}

  Future<void> _stopListen() async {
    setState(() {
      _locationSubscription.cancel();
      _locationSubscription = null;
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    setState(() {
      _locationSubscription = null;
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<TimerProvider>(
        builder: (context, timeprovider, child){
          return Scaffold(
            appBar: AppBar(
              title: Text('Session Running'),
              backgroundColor: Color(0xff4e54c8),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: ListView(
                children: [
                  Container(
                      child: Center(
                        child: SvgPicture.asset(
                            'assets/images/scooter.svg',
                            semanticsLabel: 'Trip Running',
                          width: 150,
                        )
                      ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: SpinKitRipple(
                      color: Colors.purple,
                      size: 50.0,
                    )
                  ),
                  SizedBox(height: 20),
                  Center(child: Text('Enter Current meter reading before end the Trip',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),)),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                      child: Wrap(
                        children: [
                          TextFormField(
                            autofocus: true,
                            cursorColor: Colors.purpleAccent,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.purpleAccent),
                            validator: (val) => val.isEmpty ? 'Enter End Meter Reading' : null,
                            onChanged: (val) {
                              setState(() => end_meter_reading = val);
                            },
                            decoration: new InputDecoration(
                              errorStyle: TextStyle(color: Colors.red[200]),
                              prefixIcon: Icon(
                                Icons.av_timer_rounded,
                                color: Colors.purpleAccent,
                              ),
                              labelText: "Trip End Meter Reading",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                borderSide: new BorderSide(
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                          ),
                          SizedBox(height: 20, width: 20,),
                          TextFormField(
                            autofocus: false,
                            cursorColor: Colors.purpleAccent,
                            keyboardType: TextInputType.text,
                            style: TextStyle(color: Colors.purpleAccent),
                            validator: (val) => val.isEmpty ? 'Enter Trip End Location' : null,
                            onChanged: (val) {
                              setState(() => trip_stop_location = val);
                            },
                            decoration: new InputDecoration(
                              errorStyle: TextStyle(color: Colors.red[200]),
                              prefixIcon: Icon(
                                Icons.my_location,
                                color: Colors.purpleAccent,
                              ),
                              labelText: "Trip End Location",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                borderSide: new BorderSide(
                                ),
                              ),
                              //fillColor: Colors.green
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: InkWell(
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
                      _is_saving ? "Please wait..." : 'End the Trip',
                      style: TextStyle(
                          color: Colors.white,fontSize: 20),),
                  ),
                ),
                onTap: () async {
                  if(_formKey.currentState.validate()){
                    FocusScope.of(context).requestFocus(FocusNode());
                    _is_saving ? null :
                    _is_saving = true;

                  _is_saving = true;
                  setState(() {
                     _stopListen();
                  });
                  SharedPreferences localStorage = await SharedPreferences.getInstance();
                  localStorage.setBool('tripRunning',false);
                  Navigator.push(
                  context,
                  new MaterialPageRoute(
                  builder: (context) => TripSuccess(
                      end_meter_reading:end_meter_reading,
                      trip_stop_location:trip_stop_location,
                      trip_id: tripId,
                      end_time :DateFormat('hh:mm:ss').format(DateTime.now())
                  )
                  ),
                  );
                  _is_saving = false;
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
