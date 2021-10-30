import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/database/session_table_helper.dart';
import 'package:new_field_visit_app/models/SessionSQL.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/session/offlineSessionSingle.dart';

class OfflineSessions extends StatefulWidget {
  @override
  _OfflineSessionsState createState() => _OfflineSessionsState();
}

class _OfflineSessionsState extends State<OfflineSessions> {
  List<Session> SessionList = [];
  bool _loading = false;
  bool _isUploading = false;
  String start_address = '';
  String end_address = '';
  int _sessionCount= 0;
  Session selectedSession;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSessionData();
  }
  @override
  void dispose() {
    super.dispose();
  }

  getSessionData() async{
    await SessionDBHelper.instance.getSessionList().then((value) {
      setState(() {
        SessionList = value;
        _loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if(!_loading) {
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
              title: Text('Offline Sessions ($_sessionCount)'),

              centerTitle: true,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: SessionList.length,
                            itemBuilder: (BuildContext context, index) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _sessionCount = SessionList.length;
                                });
                              });
                              if(SessionList.isEmpty) {
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
                                    child: ListTile(
                                      title: Text(SessionList[index].client),
                                      subtitle: Text(SessionList[index].date),
                                    ),
                                  ),
                                  onTap: () {
                                    var data = {
                                      'id' : SessionList[index].id,
                                      'start_address': SessionList[index]
                                          .start_address,
                                      'start_lat': SessionList[index]
                                          .start_lat,
                                      'start_long': SessionList[index]
                                          .start_long,
                                      'start_time': SessionList[index]
                                          .start_time,
                                      'description': SessionList[index]
                                          .description,
                                      'purpose': SessionList[index]
                                          .purpose,
                                      'client': SessionList[index]
                                          .client,
                                      'date': SessionList[index]
                                          .date,
                                      'end_lat': SessionList[index]
                                          .end_lat,
                                      'end_long': SessionList[index]
                                          .end_long,
                                      'end_address': SessionList[index]
                                          .end_address,
                                      'end_time': SessionList[index]
                                          .end_time
                                    };
                                    Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) => OfflineSessionSingle(data:data)
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                        )
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
