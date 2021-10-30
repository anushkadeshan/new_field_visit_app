import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/database/session_table_helper.dart';
import 'package:new_field_visit_app/models/SessionSQL.dart';
import 'package:new_field_visit_app/screens/home.dart';

class OfflineSessionSingle extends StatefulWidget {
Map data;
OfflineSessionSingle({Map data}){
  this.data = data;
}
  @override
  _OfflineSessionSingleState createState() => _OfflineSessionSingleState();
}

class _OfflineSessionSingleState extends State<OfflineSessionSingle> {
  String _connectionStatus = 'Unknown';
  bool _loading = false;
  bool _is_saving = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _descriptionController = TextEditingController();

  String _description = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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
      setState(() {
        _loading = false;
      });

    }

    return await _updateConnectionStatus(result);
  }
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(!_loading) {
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
              title: Text('Offline Sessions'),

              centerTitle: true,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 20,),
                  ListTile(
                    title: Text('Client Name',style: TextStyle(color: Colors.white)),
                    subtitle: Text(widget.data['client'],style: TextStyle(color: Colors.white60)),
                    leading: Icon(Icons.person_pin,color: Colors.white),
                  ),
                  ListTile(
                    title: Text('Purpose of Visit',style: TextStyle(color: Colors.white)),
                    subtitle: Text(widget.data['purpose'],style: TextStyle(color: Colors.white60)),
                    leading: Icon(Icons.directions_car,color: Colors.white),
                  ),
                  ListTile(
                    title: Text('Description of Visit',style: TextStyle(color: Colors.white)),
                    subtitle: Text(widget.data['description'],style: TextStyle(color: Colors.white60)),
                    leading: Icon(Icons.file_present,color: Colors.white),
                  ),
                  ListTile(
                    title: Text('Current Location',style: TextStyle(color: Colors.white)),
                    subtitle: Text(widget.data['start_address'],style: TextStyle(color: Colors.white60)),
                    leading: Icon(Icons.location_on,color: Colors.white),
                  ),
                  ListTile(
                    title: Text('Session Started Time',style: TextStyle(color: Colors.white),),
                    subtitle: Text(widget.data['start_time'],style: TextStyle(color: Colors.white60)),
                    leading: Icon(Icons.timer_outlined,color: Colors.white),
                  ),
                  SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      autofocus: true,
                      minLines: 5,
                      maxLines: null,
                      initialValue: widget.data['description'] != null ? widget.data['description'] : '',
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      validator: (val) => val.isEmpty ? 'Description is required' : null,
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.file_present,
                          color: Colors.white,
                        ),
                        labelText: "Description of Visit",
                        labelStyle: TextStyle(
                            color: Colors.white
                        ),
                        fillColor: Colors.white,
                        focusedBorder: new OutlineInputBorder(
                          borderRadius:  BorderRadius.circular(18.0),
                          borderSide:  BorderSide(
                              color: Colors.white,
                          ),
                        ),
                        border: new OutlineInputBorder(
                          borderRadius:  BorderRadius.circular(18.0),
                          borderSide:  BorderSide(
                            color: Colors.white,
                            width: 10
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                      onChanged: (val) {
                        setState(() => _description = val);
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  InkWell(
                    child: Container(
                      height: 50,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          _is_saving ? "Please wait..." : 'Upload to Cloud',
                          style: TextStyle(
                              color: Colors.deepPurple,fontSize: 20),),
                      ),
                    ),
                    onTap: () async{
                      setState(() {
                        _is_saving = true;
                      });
                      widget.data['description'] = _description;
                      await SessionApi().insertSession(widget.data, 'create-session').then((value) {
                        var body = json.decode(value.body);
                        if(body['success']){
                           deleteSession();
                        }
                      });
                    },
                  ),
                ],
              ),
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
  
  deleteSession() async{

    SessionDBHelper.instance.deleteSession(widget.data['id']).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data successfully synced to the cloud',textAlign: TextAlign.center,),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _is_saving = false;
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Home()
          ),
          ModalRoute.withName("/Home")
      );
    });
  }

}
