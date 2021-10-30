import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_field_visit_app/animations/fade_animation.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/models/session.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/session/singleSession.dart';

class Sessions extends StatefulWidget {
  @override
  _SessionsState createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  bool _isLoading = false;
  int _pageIndex = 0;
  List<Session> sessionList = [];
  String _connectionStatus = 'Unknown';
  double _count = 0.2;

  Set<Marker> markers = Set();

  double initial_lat = 6.927079;
  double initial_lng = 79.861244;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
    if(_connectionStatus=='ConnectivityResult.none'|| _connectionStatus=='Unknown') {
      setState(() {
        _isLoading = false;
      });
    }
    else{
      await SessionApi().getSessions().then((value) {
        setState(() {
          sessionList = value;
        });
        double lat = double.parse(sessionList.elementAt(0).start_lat);
        double lng = double.parse(sessionList.elementAt(0).start_long);

        setState(() {
          initial_lat = lat;
          initial_lng = lng;
        });
         _onAddMarkers();
      });
    }
    setState(() {
      _isLoading = false;
    });
    return await _updateConnectionStatus(result);
  }

  Future<List<String>>  _onAddMarkers() async {
    for(var i = 0; i< sessionList.length-1; i++)  {
      // Create a new marker
      Marker resultMarker = Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: MarkerId(sessionList[i].start_long),
        infoWindow: InfoWindow(
            title: "${sessionList[i].client}",
            snippet: "${sessionList[i].start_address}"),
        position: LatLng(double.parse(sessionList[i].start_lat),
            double.parse(sessionList[i].start_long)),
      );
      // Add it to Set
      markers.add(resultMarker);
    }

  }
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: _pageIndex);
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
          child: Scaffold(
            appBar: AppBar(
              title: Text('My Field Sessions'),
              backgroundColor: Color(0xff4e54c8),
              actions: [
                  TextButton.icon(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 10)),
                      backgroundColor: MaterialStateProperty.all(Colors.purple)
                    ),
                      icon: Icon(_pageIndex== 0 ? Icons.map :Icons.list ,color: Colors.white,),
                    label: Text(_pageIndex== 0 ? 'Map' :'List',style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        if (controller.hasClients) {
                          setState(() {
                            _pageIndex =_pageIndex== 0? 1 :0;
                          });
                          controller.animateToPage(
                            _pageIndex,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                  ),
              ],
            ),
            body: PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children:  <Widget>[
                Container(
                    color: Colors.white70,
                    padding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: sessionList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final id = index + 1;
                          if (sessionList.isEmpty) {
                            return Container(
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
                              child: Text('No Data'),
                            );
                          }
                          else {
                            return GestureDetector(
                              child: FadeAnimation(_count,
                              Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration:
                                  BoxDecoration(color: Colors.deepPurpleAccent),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    leading: Container(
                                      padding: EdgeInsets.only(right: 12.0),
                                      decoration: new BoxDecoration(
                                          border: new Border(
                                              right: new BorderSide(
                                                  width: 1.0,
                                                  color: Colors.white24))),
                                      child: Text('$id',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(
                                      (sessionList[index].client) ??
                                          '',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        text: (sessionList[index].date),
                                        style: TextStyle(color: Colors.white70),
                                        children:  <TextSpan>[
                                          TextSpan(text: ' at ', style: TextStyle(color: Colors.white70)),
                                          TextSpan(text: '${sessionList[index].start_time}', style: TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    ),

                                  ),
                                ),
                              ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            SingleSession(singleSession : sessionList[index]))
                                );
                              },
                            );
                          }
                        }
                    )
                ),
                Container(
                  child: Stack(
                    children: [
                    Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GoogleMap(
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      compassEnabled: true,
                      rotateGesturesEnabled: true,
                      mapToolbarEnabled: true,
                      tiltGesturesEnabled: true,
                      markers:markers,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      onMapCreated: _onMpaCreate,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(initial_lat,initial_lng),
                        zoom: 10,
                      ),
                    ),
                  ),
                  ]
                ),
                ),
              ],
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
