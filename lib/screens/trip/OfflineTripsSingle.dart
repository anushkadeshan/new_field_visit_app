import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_field_visit_app/api/TripApi.dart';
import 'package:new_field_visit_app/database/trip_table_helper.dart';
import 'package:new_field_visit_app/models/TripSQL.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/trip/offline_trips.dart';
import 'dart:math' show cos, sqrt, asin;

class OfflineTripSingle extends StatefulWidget {
  String tripId;
  OfflineTripSingle({String tripId}){
    this.tripId = tripId;
  }
  @override
  _OfflineTripSingleState createState() => _OfflineTripSingleState();
}

class _OfflineTripSingleState extends State<OfflineTripSingle> {
  String _connectionStatus = 'Unknown';
  bool _loading = false;
  bool _saving = false;
  List<Trip> tripData = [];

  final Set<Polyline> _polylines = {};
  List<LatLng> latlng = [];
  Trip selectedTrip;

  double totalDistanceSum =0;
  String date = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static const LatLng _initialCameraPosition = const LatLng(6.927079, 79.861244);
  Completer<GoogleMapController> _controller = Completer();

  void _onMpaCreate(GoogleMapController googleMapController){
    _controller.complete(googleMapController);
  }
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<String>>  _onAddPolulines() async {
    double totalDistance = 0;
     for(var i = 0; i< tripData.length-1; i++)  {
           LatLng data =   LatLng(tripData[i].latitude, tripData[i].longitude);
           latlng.add(data);
           totalDistance += calculateDistance(tripData[i].latitude, tripData[i].longitude, tripData[i+1].latitude, tripData[i+1].longitude);
           setState(() {
             _polylines.add(Polyline(
               polylineId: PolylineId((tripData[i].latitude).toString()),
               visible: true,
               //latlng is List<LatLng>
               points: latlng,
               color: Colors.green,
               width: 5,
               startCap: Cap.roundCap,
               endCap: Cap.roundCap
             ));
             totalDistanceSum = totalDistance;
           });
        }

  }
  void dispose() {
    _loading = true;
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    setState(() {
      _loading = true;
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
        _loading = false;
      });
    }
    else{
      await TripDBHelper.instance.viewTrip(widget.tripId).then((value) {
        setState(() {
          tripData = value;
          _loading = false;
        });
        if(tripData.length>0)  {
           _onAddPolulines();
        }
      });

    }
    return await _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    if(!_loading){
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
      else{
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
                      target: _initialCameraPosition,
                      zoom: 12,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                    left: 10,
                    child: TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.deepPurpleAccent)
                      ),
                      icon: Icon(Icons.cloud,color: Colors.white,),
                      label: Text( _saving ? 'Please wait this will take long..': 'Upload Field Trip Data to Cloud', style: TextStyle(color: Colors.white),),
                      onPressed: () async {
                        setState(() {
                          _saving = true;
                        });
                       await _uploadData();

                      },
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

  _uploadData() async {
    for(var i = 0; i< tripData.length; i++)  {
      var data = {
        'date' : tripData[i].date,
        'start_meter_reading': tripData[i].start_meter_reading,
        'trip_id': tripData[i].trip_id,
        'latitude': tripData[i].latitude,
        'longitude': tripData[i].longitude,
        'accuracy':tripData[i].accuracy,
        'altitude': tripData[i].altitude,
        'speed': tripData[i].speed,
        'end_meter_reading': tripData[i].end_meter_reading,
        'time' : tripData[i].time,
        'end_time' : tripData[i].end_time,
        'start_time': tripData[i].start_time,
        'distance' : totalDistanceSum
      };
      await TripApi().insertTrip(data, 'create-trip').then((response) async {
        var body = json.decode(response.body);
        if(response.statusCode==200 || body['success'])  {
          print('upload success');
          await TripDBHelper.instance.deleteTrip(tripData[i]).then((value) {
            print('delete success');
          });
        }
        else{
          print('not ok');
        }
      });
      if((i+1)==tripData.length){
        ScaffoldMessenger.of(
            context).showSnackBar(
          SnackBar(
            content: const Text(
                'Trip Data uploaded successfully'),
            backgroundColor: Colors
                .green,
            action: SnackBarAction(
              label: '☑',
              onPressed: () {},
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => OfflineTrips()
            ),
            ModalRoute.withName("/OfflineTrips")
        );
      }
    }
    setState(() {
      _saving = false;
    });
  }

}
