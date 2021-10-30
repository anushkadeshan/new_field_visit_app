import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/models/session.dart';
import 'package:new_field_visit_app/screens/home.dart';

class SessionsGoogleMap extends StatefulWidget {
  final Function toggleView;
  SessionsGoogleMap({ this.toggleView });

  @override
  _SessionsGoogleMapState createState() => _SessionsGoogleMapState();
}

class _SessionsGoogleMapState extends State<SessionsGoogleMap> {
  bool _isLoading = false;
  List<Session> sessionList = [];
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
      await SessionApi().getSessions().then((value) {
        setState(() {
          sessionList = value;
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
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('My Field Sessions Map View'),
              backgroundColor: Color(0xff4e54c8),
              actions: [
                TextButton.icon(
                  icon: Icon(Icons.person,color: Colors.white,),
                  label: Text('Sign Up',style: TextStyle(color: Colors.white)),
                  onPressed: () => widget.toggleView(),
                ),
              ],
            ),
            body: Container(
                color: Colors.white70,
                padding:
                EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: sessionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final id = index + 1;
                      return Card(
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          decoration:
                          BoxDecoration(color: Colors.lightBlueAccent),
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
                              (sessionList[index].date).toString() ??
                                  '',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Text(
                                    (sessionList[index].date).toString() ??
                                        '',
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              iconSize: 30.0,
                              onPressed: () async {

                              },
                            ),
                          ),
                        ),
                      );
                    }
                )
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
