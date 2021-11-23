import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:new_field_visit_app/screens/session/session_success.dart';
import 'package:new_field_visit_app/screens/session/time_provider.dart';
import 'package:provider/provider.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class SessionRunning extends StatefulWidget {
  double start_lat;
  double start_long;
  String start_address;
  String start_time;
  String description;
  String purpose;
  String date;
  String client;

  SessionRunning({String start_address, double start_lat, double start_long,String start_time,String description,String purpose, String client, String date }){
    this.start_lat = start_lat;
    this.start_address = start_address;
    this.start_long = start_long;
    this.start_time = start_time;
    this.description = description;
    this.purpose = purpose;
    this.date = date;
    this.client = client;

  }
  @override
  _SessionRunningState createState() => _SessionRunningState();
}

class _SessionRunningState extends State<SessionRunning> {
  bool _is_saving = false;
  var timer;
  double end_lat;
  double end_long;
  String end_address  = '';
  bool serviceEnabled = false;
  bool imagePicking = false;
  String errorMessage = '';
  String imagePath = '';

  @override
  void initState() {
    // TODO: implement initState
    timer = Provider.of<TimerProvider>(context, listen: false);
    timer.startTimer();
    super.initState();
  }

  _checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
    // ignore: unrelated_type_equality_checks
    if(permission == LocationPermission.whileInUse || permission ==LocationPermission.always){
      await _checkLocationServiceEnabled();
      //print("1");
    }

    else{
      _requestLocationPermission();
    }
  }

  _checkLocationServiceEnabled() async {
    bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
    if(isLocationServiceEnabled==true){
      await _getCurrentLocation();
      //print("2");
      //print('location in your phone');
    }
    else{
      serviceEnabled = false;
      print('please enable location in your phone');
    }
  }

  _requestLocationPermission() async{
    LocationPermission permission = await Geolocator.requestPermission();
    // ignore: unrelated_type_equality_checks
    if(permission == LocationPermission.whileInUse ||permission ==LocationPermission.always){
      await _checkLocationServiceEnabled();
      //print("3");
    }
    else{
      print('you cant use this app bt');
    }
  }

  _getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position==null){

    }
    else{
      //print("4");
      end_lat = position.latitude;
      end_long = position.longitude;
      await _getAddress(end_lat,end_long);
    }
  }

  _getAddress(lat,long) async{
    try{
    final coordinates = new Coordinates(lat, long);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print(addresses.first.addressLine);
    final first = addresses.first;
    setState(() {
      serviceEnabled = true;
      end_address = "${first.addressLine}";
    });
    }
    catch(e){
      setState(() {
        serviceEnabled = true;
        end_address = "";
      });
    }
  }

  File uploadimage; //variable for choosed file
  final picker = ImagePicker();
  Future<void> chooseImage() async {
    setState(() {
      imagePicking = true;
    });
    final choosedimage = await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      if (choosedimage != null) {
        uploadimage = File(choosedimage.path);
        imagePath = choosedimage.path;
        imagePicking = false;
      } else {
        print('No image selected.');
      }
    });
  }
  Widget build(BuildContext context) {
    return Container(child: Consumer<TimerProvider>(
        builder: (context, timeprovider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Session Running'),
              backgroundColor: Color(0xff4e54c8),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xff4e54c8),
                        border: Border.all(
                          color: Colors.blueGrey[500],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: DigitalClock(
                        showSecondsDigit: true,
                        digitAnimationStyle: Curves.slowMiddle,
                        is24HourTimeFormat: true,
                        areaDecoration: BoxDecoration(
                          color: Color(0xff4e54c8),
                        ),
                        hourMinuteDigitTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                        secondDigitTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ListTile(
                    title: Text('Client Name'),
                    subtitle: Text(widget.client),
                    leading: Icon(Icons.person_pin),
                  ),
                  ListTile(
                    title: Text('Purpose of Visit'),
                    subtitle: Text(widget.purpose),
                    leading: Icon(Icons.directions_car),
                  ),
                  ListTile(
                    title: Text('Description of Visit'),
                    subtitle: Text(widget.description),
                    leading: Icon(Icons.file_present),
                  ),
                  ListTile(
                    title: Text('Current Location'),
                    subtitle: Text(widget.start_address),
                    leading: Icon(Icons.location_on),
                  ),
                  ListTile(
                    title: Text('Session Started Time'),
                    subtitle: Text(widget.start_time),
                    leading: Icon(Icons.timer_outlined),
                  ),
                  SizedBox(height: 20,),

                  Container(

                    child: TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent)
                      ),
                      onPressed: (){
                        chooseImage(); // call choose image function
                      },
                      icon:Icon(Icons.folder_open,color: Colors.white,),
                      label: Text(imagePicking ? "PLEASE WAIT" : "CHOOSE IMAGE",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Center(
                    child: uploadimage != null ? Container(
                      child:Image.file(uploadimage),
                    ) : Container(
                      child: Text(errorMessage, style: TextStyle(color: Colors.redAccent),),
                    ),
                  ),

                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: InkWell(
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
                      _is_saving ? "Please wait..." : 'End the Session',
                      style: TextStyle(
                          color: Colors.white,fontSize: 20),),
                  ),
                ),
                onTap: () async{
                  if(uploadimage != null) {
                    _is_saving = true;
                    List<int> imageBytes = uploadimage.readAsBytesSync();
                    String baseimage = base64Encode(imageBytes);

                    await _checkLocationPermission();
                    if (serviceEnabled) {
                      String end_time = DateFormat('hh:mm:ss').format(
                          DateTime.now());
                      var data = {
                        'start_address': widget.start_address,
                        'start_lat': widget.start_lat,
                        'start_long': widget.start_long,
                        'start_time': widget.start_time,
                        'description': widget.description,
                        'purpose': widget.purpose,
                        'client': widget.client,
                        'date': widget.date,
                        'end_lat': end_lat,
                        'end_long': end_long,
                        'end_address': end_address,
                        'end_time': end_time,
                        'image' : baseimage
                      };

                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => SessionSuccess(data: data, imagePath: imagePath)
                        ),
                      );
                      _is_saving = false;
                    }
                    else {
                      print('Np');
                      _is_saving = false;
                    }
                  }else{
                    setState(() {
                      errorMessage = 'Please attach an image to complete the session';
                    });
                  }
                },
              ),
            ),
          );
        }
      ));
  }
}
