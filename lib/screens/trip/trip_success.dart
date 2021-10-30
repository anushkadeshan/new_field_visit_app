import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/database/trip_table_helper.dart';
import 'package:new_field_visit_app/models/TripSQL.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/trip/offline_trips.dart';


class TripSuccess extends StatefulWidget {
  String end_meter_reading;
  String trip_id;
  String end_time;

  TripSuccess({String end_meter_reading, String trip_id, String end_time }){
    this.end_meter_reading = end_meter_reading;
    this.trip_id = trip_id;
    this.end_time = end_time;
  }
  @override
  _TripSuccessState createState() => _TripSuccessState();
}

class _TripSuccessState extends State<TripSuccess> {
  bool isLoading = false;
  bool saved = false;
  String displayMessage = '';

  double totalDistance;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    // TODO: implement initState
    super.initState();
    updateTripTable();
  }

  List<dynamic> data = [];
  updateTripTable() async{
    await TripDBHelper.instance.updateTrip2(widget.end_meter_reading, widget.trip_id, widget.end_time).then((value) {
      if(value != null) {
        print('success');
        setState(() {
          isLoading = false;
          saved = true;
          displayMessage = 'Field Trip successfully saved to your local storage.';
        });

      }
      else{
        print('error');
        setState(() {
          isLoading = false;
          displayMessage = 'Something Error';
        });
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    if(!isLoading)
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
          title: Text('Field Trip Data'),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: saved ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, color: Colors.yellow,size: 100,),
                SizedBox(height: 20,),
                Text(displayMessage, style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                Text('* You need to send this trip data to Cloud when you have mobile network', style: TextStyle(fontSize: 12,color: Colors.redAccent,fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
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
                        'View Offline Trips',
                        style: TextStyle(
                            color: Colors.white,fontSize: 20),),
                    ),
                  ),
                  onTap: () {

                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => OfflineTrips()
                      ),
                    );

                  },
                ),
              ],
            ) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, color: Colors.yellow,size: 100,),
                SizedBox(height: 20,),
                Text(displayMessage, style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                Text('* Please contact Developer', style: TextStyle(fontSize: 12,color: Colors.redAccent,fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
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

                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => Home()
                      ),
                    );

                  },
                ),
              ],
            )
          ),
        ),
      ),
    );
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
