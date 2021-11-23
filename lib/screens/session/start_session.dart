import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:new_field_visit_app/screens/session/session_running.dart';

class SessionStart extends StatefulWidget {
   @override
  _SessionStartState createState() => _SessionStartState();
}

class _SessionStartState extends State<SessionStart> {
  bool is_loading = false;
  bool serviceEnabled = false;
  double start_lat;
  double start_long;
  String start_address  = '';
  bool _is_saving = false;

  void initState() {
    // TODO: implement initState
    is_loading = true;
    _checkLocationPermission();
    super.initState();
  }

  _checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
    // ignore: unrelated_type_equality_checks
    if(permission == LocationPermission.whileInUse || permission ==LocationPermission.always){
      _checkLocationServiceEnabled();
    }

    else{
      _requestLocationPermission();
    }
  }

  _checkLocationServiceEnabled() async {
    bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
    if(isLocationServiceEnabled==true){
      _getCurrentLocation();
      print('location in your phone');
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
      _checkLocationServiceEnabled();
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
      start_lat = position.latitude;
      start_long = position.longitude;
      _getAddress(start_lat,start_long);
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
      is_loading = false;
      start_address = "${first.addressLine}";
    });
    }
    catch(e){
      setState(() {
        serviceEnabled = true;
        is_loading = false;
        start_address = "";
      });
    }
  }
  final _formKey = GlobalKey<FormState>();
  String date = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  String start_time = DateFormat('hh:mm:ss').format(DateTime.now());
  final List<String> _purposes = [
    'Advocacy Campaigns',
    'Baseline/Evaluation',
    'BMIC Branch Visits',
    'BSS Scholarships',
    'Community Development Projects',
    'Education Project Activities',
    'EIP Client Visits',
    'Livelihood',
    'Meetup Stakeholders',
    'Monitoring Visits to Beneficiary/Project',
    'Other',
    'Visit CBOs/CSOs Meeting',
    'Workshops or Training Programs for Youth',

  ];
  String _description;
  String _purpose ;
  String _client;
  bool _other_field = false;

  @override
  Widget build(BuildContext context) {
    if(!is_loading) {
      return Container(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff4e54c8),
            title: Text('Initial Data'),
          ),
          body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              child: Form(
                key: _formKey,
                child: Wrap(
                  spacing: 20.0,
                  children: [
                    SizedBox(height: 20.0),
                    Center(child: Text('Add Below data before start the Session',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color: Colors.deepPurple),)),

                    SizedBox(height: 20.0),
                    DropdownButtonFormField(
                      isExpanded: true,
                      autofocus: true,
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 15.0),
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.directions_car,
                          color: Colors.purpleAccent,
                        ),
                        labelText: "Reason to Visit",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          borderSide: new BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                      items: _purposes.map((String myPurpose) {
                        return DropdownMenuItem(
                          value: myPurpose,
                          child: Text('$myPurpose'),
                        );
                      }).toList(),
                      validator: (val) => val ==null ? 'Select Field Visit Purpose' : null,
                      onChanged: (val) {
                        if(val=='Other'){
                          setState(() => _other_field = true);
                        }
                        else{
                          _other_field = false;
                          setState(() => _purpose = val);
                        }
                      },
                    ),

                    SizedBox(height: 20.0),
                    _other_field == true ?
                    TextFormField(
                      autofocus: true,
                      cursorColor: Colors.purpleAccent,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.purpleAccent),
                      validator: (val) => val.isEmpty ? 'This field is required' : null,
                      onChanged: (val) {
                        setState(() => _purpose = val);
                      },
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.directions_car,
                          color: Colors.purpleAccent,
                        ),
                        labelText: "Specify Reason",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          borderSide: new BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                    ) : SizedBox(height: 1.0),
                    SizedBox(height: 20.0),
                    TextFormField(
                      autofocus: true,
                      cursorColor: Colors.purpleAccent,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.purpleAccent),
                      validator: (val) => val.isEmpty ? 'Enter Client Name' : null,
                      onChanged: (val) {
                        setState(() => _client = val);
                      },
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.person_pin,
                          color: Colors.purpleAccent,
                        ),
                        labelText: "Client Name",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          borderSide: new BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      autofocus: true,
                      minLines: 5,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.purpleAccent,
                      style: TextStyle(color: Colors.purpleAccent),
                      validator: (val) => val.isEmpty ? 'Description is required' : null,
                      onChanged: (val) {
                        setState(() => _description = val);
                      },
                      decoration: new InputDecoration(
                        errorStyle: TextStyle(color: Colors.red[200]),
                        prefixIcon: Icon(
                          Icons.file_present,
                          color: Colors.purpleAccent,
                        ),
                        labelText: "Description of Visit",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          borderSide: new BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                    ),



                    SizedBox(height: 20.0),

                  ],
                ),
              ),
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
                      _is_saving ? "Please Wait..." : 'Start the Session' ,
                      style: TextStyle(color: Colors.white, fontSize: 20),),
                  ),
                ),
                onTap: (){
                  if(_formKey.currentState.validate()){
                    _is_saving ? null :
                    _is_saving = true;
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => SessionRunning(
                              start_address: start_address,
                              start_lat: start_lat,
                              start_long: start_long,
                              start_time: start_time,
                              description:_description,
                              purpose: _purpose,
                              client: _client,
                              date: date

                          )
                      ),
                    );
                    _is_saving = false;
                  }
                },
              ),
            )
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
