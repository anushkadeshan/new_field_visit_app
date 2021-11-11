import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:new_field_visit_app/animations/fade_animation.dart';
import 'package:new_field_visit_app/api/TripApi.dart';
import 'package:new_field_visit_app/models/trip.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/trip/single_trip.dart';

class Trips extends StatefulWidget {

  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  bool _isLoading = false;
  List<Trip> tripList = [];
  String _connectionStatus = 'Unknown';
  double _count = 0.2;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  void dispose() {
    _isLoading = true;
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    setState(() {
      _isLoading = true;
    });
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    setState(() {
      _connectionStatus = result.toString();
    });
    if(_connectionStatus=='ConnectivityResult.none'|| _connectionStatus=='Unknown') {
      setState(() {
        _isLoading = false;
      });
    }
    else{
      await TripApi().getTrips().then((value) {
        setState(() {
          tripList = value;
        });
      });
    }
    setState(() {
      _isLoading = false;
    });
    return await _updateConnectionStatus(result);
  }
  @override
  Widget build(BuildContext context) {
    if(!_isLoading) {
      if (_connectionStatus == 'ConnectivityResult.none' ||
          _connectionStatus == 'Unknown') {
        return Container(
          child: Scaffold(
            appBar: AppBar(
              title: Text('No Internet'),
              backgroundColor: Color(0xff4e54c8),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.redAccent,size: 150,),
                    SizedBox(height: 20,),
                    Text('Please Check Your Internet Connection', style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                    SizedBox(height: 20,),
                    InkWell(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xff4e54c8),
                                  Color.fromRGBO(143, 148, 251, 1),
                                ]
                            )
                        ),
                        child: Center(
                          child: Text(
                            'Back to Home',
                            style: TextStyle(
                                color: Colors.white,fontSize: 20),),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Home()
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      else {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff4e54c8),
                    Color(0xff5f65d6),
                    Color(0xff7378e5),
                    Color(0xff8b90f8)
                  ])),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Trips Data'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            body: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: tripList.length, itemBuilder: (BuildContext context, index){
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _count += (index/5);
                        });
                      });
                      if (tripList.isEmpty) {
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            spreadRadius: 3,
                            color: Colors.white.withOpacity(0.2)
                          )
                        ]
                        ),
                        child: Text('sdsdsdsd'),
                        ),
                      );
                      }
                      else {
                        return GestureDetector(
                          child: FadeAnimation(_count, Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 3,
                                        spreadRadius: 3,
                                        color: Colors.white.withOpacity(0.2)
                                    )
                                  ]
                              ),
                              child: ListTile(
                                  title: Text((tripList[index].trip_start_location).toString()+ ' to '+(tripList[index].trip_end_location).toString() + ' on ' +(tripList[index].date).toString()),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      text: (tripList[index].distance).toStringAsPrecision(2),
                                      style: TextStyle(color: Colors.black54),
                                      children: const <TextSpan>[
                                        TextSpan(text: 'km', style: TextStyle(color: Colors.black54)),
                                        TextSpan(text: ' of distance', style: TextStyle(color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                  //title: Text(tripList[index].start_meter_reading== null ? 'Null' : tripList[index].start_meter_reading),
                                  //subtitle: Text(tripList[index].end_meter_reading == null ? 'Null' :tripList[index].end_meter_reading),
                                  trailing: IconButton(
                                      icon: Icon(Feather.arrow_right_circle),
                                      onPressed: () =>
                                      {
                                       Navigator.push(
                                           context,
                                           new MaterialPageRoute(
                                               builder: (context) =>
                                                   SingleTrip(tripId :tripList[index].trip_id))
                                       )
                                      }
                                  ),
                                ),

                            ),
                          ),
                        );
                      }
                      }
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
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

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          _connectionStatus = result.toString();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          _connectionStatus = result.toString();
        });
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

}
