import 'dart:async';
import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/database/session_table_helper.dart';
import 'package:new_field_visit_app/models/SessionSQL.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/session/offline_sessions.dart';

class SessionSuccess extends StatefulWidget {
  Map data;
  String imagePath;

  SessionSuccess({Map data, String imagePath }){
    this.data = data;
    this.imagePath = imagePath;
  }
  @override

  _SessionSuccessState createState() => _SessionSuccessState();
}

class _SessionSuccessState extends State<SessionSuccess> {
  String _connectionStatus = 'Unknown';

  bool is_loading = false;
  bool savedAPI = false;
  String displayMessage = '';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override

  void initState(){
    // TODO: implement initState

    super.initState();
     initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    setState(() {
      is_loading = true;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Internet Connection',textAlign: TextAlign.center,),
          backgroundColor: Colors.red,
        ),
      );
     await SaveToSQL();
    }
    else{
      await saveToAPI();
          }
    setState(() {
      is_loading = false;
    });
    return await _updateConnectionStatus(result);
  }


  @override
  Widget build(BuildContext context) {
    if (!is_loading) {
    return Container(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => Home()
                  ),
                );
              },
            ),
            backgroundColor: Color(0xff4e54c8),
            title: Text('Session Data'),
            centerTitle: true,
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
              child: savedAPI ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up, color: Colors.green,size: 100,),
                  SizedBox(height: 20,),
                  Text(displayMessage, style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
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
                          'Back to Home',
                          style: TextStyle(
                              color: Colors.white,fontSize: 20),),
                      ),
                    ),
                    onTap: () {

                        Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Home()
                          ),
                          ModalRoute.withName("/Home")

                        );

                    },
                  ),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up, color: Colors.yellow,size: 100,),
                  SizedBox(height: 20,),
                  Text(displayMessage, style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                  SizedBox(height: 20,),
                  Text('* You need to send this session data to BDS MIS when you have mobile network', style: TextStyle(fontSize: 12,color: Colors.redAccent,fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
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
                          'View Offline Sessions',
                          style: TextStyle(
                              color: Colors.white,fontSize: 20),),
                      ),
                    ),
                    onTap: () {

                      Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OfflineSessions()
                        ), ModalRoute.withName("/offlinesessions")
                      );

                    },
                  ),
                ],
              ),
            ),
          ),
        )
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
  SaveToSQL() async {
    Session session = Session(
      client : widget.data['client'],
      date : widget.data['date'],
      start_address : widget.data['start_address'],
      description : widget.data['description'],
      end_address : widget.data['end_address'],
      start_lat : widget.data['start_lat'],
      end_lat : widget.data['end_lat'],
      start_long : widget.data['start_long'],
      end_long : widget.data['end_long'],
      start_time : widget.data['start_time'],
      end_time : widget.data['end_time'],
      created_at : widget.data['created_at'],
      updated_at : widget.data['updated_at'],
      purpose : widget.data['purpose'],
      image : widget.imagePath
    );

    await SessionDBHelper.instance.insertSession(session).then((value) {
      print(value);
      if(value!= null){
        setState(() {
          displayMessage = 'Your Session data has been successfully saved to your phone';
          savedAPI = false;
        });
      }
      else{

      }
    });
  }

  saveToAPI() async {
    await SessionApi().insertSession(widget.data, 'create-session').then((response){
      var body = json.decode(response.body);
      if(response.statusCode==201 || body['success']){
        setState(() {
          displayMessage = 'Your Session data has been successfully saved to the BDS MIS';
          savedAPI = true;
        });
      }
      else{
         SaveToSQL();
      }
    });
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.mobile:
      setState(() => _connectionStatus = result.toString());
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
