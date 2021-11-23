import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:new_field_visit_app/database/trip_table_helper.dart';
import 'package:new_field_visit_app/models/TripSQL.dart';
import 'package:new_field_visit_app/screens/trip/OfflineTripsSingle.dart';

class OfflineTrips extends StatefulWidget {

  @override
  _OfflineTripsState createState() => _OfflineTripsState();
}

class _OfflineTripsState extends State<OfflineTrips> {
  List<Trip> tripList = [];
  bool _loading = false;
  int _sessionCount= 0;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _loading = true;
    });
    super.initState();
    _getOfflineTrips();
  }
  _getOfflineTrips() async{
    await TripDBHelper.instance.getTripList().then((value) {
      setState(() {
        tripList = value;
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
            title: Text('Offline Trips ($_sessionCount)'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          body: Center(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: tripList.length,
                        itemBuilder: (BuildContext context, index) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _sessionCount = tripList.length;
                            });

                          });
                          if (tripList.length ==0) {
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
                            print(tripList.length);
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
                                  title: Text((tripList[index].trip_start_location).toString() +' to '+ (tripList[index].trip_end_location).toString()),
                                  subtitle: Text(
                                      getDateAndTime(tripList[index].time)),
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
                                                  OfflineTripSingle(tripId :tripList[index].trip_id))
                                      )
                                    }
                                  ),
                                ),

                              ),
                            );
                          }
                        }
                    ),
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

  getDateAndTime(timestamp){
    var dt =  DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    String string =  DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
    return string;
  }
}
