import 'dart:async';
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_field_visit_app/api/TripApi.dart';
import 'package:new_field_visit_app/models/trip.dart';
import 'package:new_field_visit_app/screens/home.dart';

class SingleTrip extends StatefulWidget {
  String tripId;
  SingleTrip({String tripId}){
    this.tripId = tripId;
  }
  @override
  _SingleTripState createState() => _SingleTripState();
}

class _SingleTripState extends State<SingleTrip> {
  bool _isLoading = false;
  List<Trip> tripList = [];
  String _connectionStatus = 'Unknown';
  final Set<Polyline> _polylines = {};
  List<LatLng> latlng = [];

  double initial_lat = 6.927079;
  double initial_lng = 79.861244;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static const LatLng _initialCameraPosition = const LatLng(6.927079, 79.861244);
  Completer<GoogleMapController> _controller = Completer();

  void _onMpaCreate(GoogleMapController googleMapController){
    _controller.complete(googleMapController);
  }
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
    if (_connectionStatus == 'ConnectivityResult.none' ||
        _connectionStatus == 'Unknown') {
      setState(() {
        _isLoading = false;
      });
    }
    else {
      var data = {
        'trip_id' : widget.tripId,
      };
      await TripApi().getSingleTrip(data).then((value) {
        setState(() {
          tripList = value;
        });
        double lat = tripList.elementAt(0).latitude;
        double lng = tripList.elementAt(0).longitude;

        setState(() {
          initial_lat = lat;
          initial_lng = lng;
        });
        if(tripList.length>0)  {
          _onAddPolulines();
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
    return await _updateConnectionStatus(result);
  }
  Future<List<String>>  _onAddPolulines() async {
    for(var i = 0; i< tripList.length-1; i++)  {
      LatLng data =   LatLng(tripList[i].latitude, tripList[i].longitude);
      latlng.add(data);
      setState(() {
        _polylines.add(Polyline(
            polylineId: PolylineId((tripList[i].latitude).toString()),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.green,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap
        ));

      });
    }

  }
  @override
  Widget build(BuildContext context) {
    if(!_isLoading){
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
                centerTitle: true,
                title: Text('Field Trip Upload'),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              body: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GoogleMap(
                      polylines:_polylines,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      onMapCreated: _onMpaCreate,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(initial_lat,initial_lng),
                        zoom: 10,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 30,
                      left: 12,
                      child: Container(
                        width: 250,
                        height: 250,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.6),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                  color: Colors.white.withOpacity(0.2)
                              )
                            ]
                        ),
                        child: Column(
                          children: [
                            Text((tripList.elementAt(0).date).toString(),style: TextStyle(color: Colors.deepPurple,fontSize: 18),),
                            SizedBox(height: 5,),
                            Text('At ' + (tripList.elementAt(0).end_time).toString(),style: TextStyle(color: Colors.deepPurple,fontSize: 14),),
                            SizedBox(height: 20,),
                            Text('Start Meter :  ' + (tripList.elementAt(0).start_meter_reading).toString(),style: TextStyle(color: Colors.black87,fontSize: 18),),
                            SizedBox(height: 20,),
                            Text('End Meter :  ' + (tripList.elementAt(0).end_meter_reading).toString(),style: TextStyle(color: Colors.black87,fontSize: 18),),
                            SizedBox(height: 20,),
                            Text('Total Distance :  ' + (tripList.elementAt(0).distance).toStringAsPrecision(2)+ ' KM',style: TextStyle(color: Colors.black87,fontSize: 18),),
                          ],
                        ),
                      )
                  )
                ],
              )
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
