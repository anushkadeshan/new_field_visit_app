import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/animations/fade_animation.dart';
import 'package:new_field_visit_app/api/SessionApi.dart';
import 'package:new_field_visit_app/api/TripApi.dart';
import 'package:new_field_visit_app/api/callApi.dart';
import 'package:new_field_visit_app/auth_provider/authProvider.dart';
import 'package:new_field_visit_app/database/session_table_helper.dart';
import 'package:new_field_visit_app/screens/login.dart';
import 'package:new_field_visit_app/screens/session/all-sessions.dart';
import 'package:new_field_visit_app/screens/session/offline_sessions.dart';
import 'package:new_field_visit_app/screens/session/start_session.dart';
import 'package:new_field_visit_app/screens/spalash.dart';
import 'package:new_field_visit_app/screens/trip/all_trips.dart';
import 'package:new_field_visit_app/screens/trip/offline_trips.dart';
import 'package:new_field_visit_app/screens/trip/start_trip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _sessionCount = 0;
  bool _loading = true;
  String _connectionStatus = 'Unknown';
  String greeting_message = '';
  double width;
  double height;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<String, dynamic> sessionData;
  Map<String, dynamic> tripData;

  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _verifyUser ();
    getOfflineSessionCount();
    greeting();
  }
  greeting() async {
    var timeOfDay = DateTime.now().hour;
    if(timeOfDay >= 0 && timeOfDay < 12){
      greeting_message = 'Good Morning';
    }else if(timeOfDay >= 12 && timeOfDay < 16){
      greeting_message = 'Good Afternoon';
    }else if(timeOfDay >= 16 && timeOfDay < 21){
      greeting_message = 'Good Evening';
    }else if(timeOfDay >= 21 && timeOfDay < 24){
      greeting_message = 'Good Night';
    }

  }
  getOfflineSessionCount() async {
    await SessionDBHelper.instance.getOfflineSessionCount().then((value) {
      setState(() {
        _sessionCount = value;
      });
    });
  }
  _verifyUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    Provider.of<Auth>(context, listen: false).tryTokenOffline(token: token);
  }
  Future<void> initConnectivity() async {
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

    }
    else{

    }
    return await _updateConnectionStatus(result);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (context, auth, child)
    {
     if (!_loading) {
       if (auth.authenticated) {
         return Container(
           child: Scaffold(
             key: _scaffoldKey,
             backgroundColor: Colors.white,
             appBar: AppBar(
               backgroundColor: Color(0xff4e54c8),
               shadowColor: Colors.transparent,
               centerTitle: true,
               title: Text('Field Visits')
               ,
             ),
             drawer: Container(
               width: MediaQuery
                   .of(context)
                   .size
                   .width > 350 ? 330 : 280,
               child: Drawer(
                   child: Consumer<Auth>(builder: (context, auth, child) {
                     if (!auth.authenticated) {
                       return ListView(
                         children: [
                           ListTile(
                             title: Text('Login'),
                             leading: Icon(Icons.login),
                             onTap: () {
                               Navigator.of(context).push(
                                   MaterialPageRoute(
                                       builder: (context) => Login()));
                             },
                           ),
                         ],
                       );
                     } else {
                       return Container(
                         decoration: BoxDecoration(
                           // Box decoration takes a gradient
                           gradient: LinearGradient(
                             // Where the linear gradient begins and ends
                             begin: Alignment.topRight,
                             end: Alignment.bottomLeft,
                             // Add one stop for each color. Stops should increase from 0 to 1
                             stops: [0.3, 0.6, 0.9],
                             colors: [
                               // Colors are easy thanks to Flutter's Colors class.
                               Color(0xff8b90f8),
                               Color(0xff7378e5),
                               Color(0xff4e54c8),
                             ],
                           ),
                         ),
                         child: ListView(
                           children: [
                             DrawerHeader(
                               child: Column(
                                 children: [
                                   CircleAvatar(
                                     backgroundColor: Colors.white,
                                     backgroundImage: auth.offline
                                         ? AssetImage('assets/images/user.png')
                                         : NetworkImage(
                                         auth.user.profilePhotoUrl),
                                     radius: 30,
                                   ),
                                   SizedBox(
                                     height: 10,
                                   ),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment
                                         .center,
                                     children: [
                                       Text(
                                         auth.user.name,
                                         style: TextStyle(color: Colors.white),
                                       ),
                                       SizedBox(
                                         height: 10,
                                       ),
                                       Text(
                                         auth.user.email,
                                         style: TextStyle(color: Colors.white),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                               decoration: BoxDecoration(
                                 color: Color(0xff8b90f8),
                               ),
                             ),
                             Column(
                               children: [
                                 Wrap(
                                   children: [
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),
                                       child: Text('Sessions',style: TextStyle(color: Colors.white)),
                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),

                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('New Session'),
                                         leading: Icon(Icons
                                             .supervised_user_circle_sharp ,color: Colors.blue,),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       SessionStart())
                                           );
                                         },
                                       ),

                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),

                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('My Offline Sessions'),
                                         leading: Icon(
                                             Icons.signal_cellular_off,color: Colors.yellow,),

                                         trailing: DecoratedBox(
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius
                                                   .circular(10),
                                               color: _sessionCount > 0 ? Colors
                                                   .red : Colors.white),

                                           child: Container(
                                               padding: EdgeInsets.symmetric(
                                                   vertical: 5, horizontal: 5),
                                               child: Text('$_sessionCount',
                                                 style: TextStyle(
                                                     color: Colors.white),)
                                           ),
                                         ),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       OfflineSessions())
                                           );
                                         },
                                       ),

                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),

                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('My Cloud Sessions'),
                                         leading: Icon(
                                             Icons.signal_cellular_4_bar_outlined,color: Colors.green,),
                                         trailing: DecoratedBox(
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius
                                                   .circular(10),
                                               color: _sessionCount > 0 ? Colors
                                                   .red : Colors.white),

                                           child: Container(
                                               padding: EdgeInsets.symmetric(
                                                   vertical: 5, horizontal: 5),
                                               child: Text('$_sessionCount',
                                                 style: TextStyle(
                                                     color: Colors.white),)
                                           ),
                                         ),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       Sessions())
                                           );
                                         },
                                       ),

                                     ),
                                     Divider(color: Colors.white,),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),
                                       child: Text('Trips',style: TextStyle(color: Colors.white),),
                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),

                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('New Trip'),
                                         leading: Icon(Icons.location_on,color: Colors.blue,),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       StartTrip())
                                           );
                                         },
                                       ),

                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('My Offline Trips'),
                                         leading: Icon(Icons.location_off,color: Colors.yellow,),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       OfflineTrips())
                                           );
                                         },
                                       ),

                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('My Cloud Trips'),
                                         leading: Icon(Icons.location_on,color: Colors.green,),
                                         onTap: () {
                                           Navigator.push(
                                               context,
                                               new MaterialPageRoute(
                                                   builder: (context) =>
                                                       Trips())
                                           );
                                         },
                                       ),

                                     ),
                                     Divider(
                                       color: Colors.white,
                                     ),
                                     Container(
                                       margin: EdgeInsets.symmetric(
                                           vertical: 5, horizontal: 8),

                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(
                                             12),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.white.withOpacity(
                                                 0.2),
                                             spreadRadius: 4,
                                             blurRadius: 5,
                                             offset: Offset(0,
                                                 4), // changes position of shadow
                                           ),
                                         ],
                                         color: Colors.white,
                                       ),
                                       child: ListTile(
                                         title: Text('Logout'),
                                         leading: Icon(Icons.logout,color: Colors.redAccent,),
                                         onTap: () async {
                                           await logout();
                                         },
                                       ),

                                     ),

                                   ],
                                 ),
                               ],
                             ),

                           ],
                         ),
                       );
                     }
                   })),
             ),
             floatingActionButton: SpeedDial(
               marginEnd: 18,
               marginBottom: 20,
               icon: Icons.add,
               activeIcon: Icons.remove,
               buttonSize: 56.0,
               visible: true,
               closeManually: false,
               renderOverlay: false,
               curve: Curves.bounceIn,
               overlayColor: Colors.black,
               overlayOpacity: 0.5,
               onOpen: () => print('OPENING DIAL'),
               onClose: () => print('DIAL CLOSED'),
               tooltip: 'Speed Dial',
               heroTag: 'speed-dial-hero-tag',
               backgroundColor: Colors.white,
               foregroundColor: Colors.black,
               elevation: 8.0,
               shape: CircleBorder(),
               // orientation: SpeedDialOrientation.Up,
               // childMarginBottom: 2,
               // childMarginTop: 2,
               children: [
                 SpeedDialChild(
                   child: Icon(Icons.location_on),
                   backgroundColor: Colors.red,
                   label: 'Start a Trip',
                   labelStyle: TextStyle(fontSize: 18.0),
                   onTap: () =>
                       Navigator.push(
                           context,
                           new MaterialPageRoute(
                               builder: (context) => StartTrip())
                       ),
                   onLongPress: () => print('FIRST CHILD LONG PRESS'),
                 ),
                 SpeedDialChild(
                   child: Icon(Icons.supervised_user_circle_sharp),
                   backgroundColor: Colors.blue,
                   label: 'Start a Session',
                   labelStyle: TextStyle(fontSize: 18.0),
                   onTap: () =>
                       Navigator.push(
                           context,
                           new MaterialPageRoute(
                               builder: (context) => SessionStart())
                       ),
                   onLongPress: () => print('SECOND CHILD LONG PRESS'),
                 ),
               ],
             ),
             body: SingleChildScrollView(
               child: Column(
                 children: [
                   Container(
                     padding: EdgeInsets.symmetric(vertical: 20),
                     decoration: BoxDecoration(
                         color: Color(0xff4e54c8),
                         borderRadius: BorderRadius.only(
                             bottomRight: Radius.circular(25),
                             bottomLeft: Radius.circular(25))
                     ),
                     child: Column(
                       children: [
                         FadeAnimation(0.5, Container(
                           height: 130,
                           width: double.infinity,
                           margin: EdgeInsets.symmetric(
                               vertical: 7, horizontal: 20),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Row(
                             children: [
                               Container(
                                 height: double.infinity,
                                 width: 120,
                                 decoration: BoxDecoration(
                                     color: Colors.blue,
                                     borderRadius: BorderRadius.circular(20),
                                     image: DecorationImage(
                                         image: AssetImage(
                                             'assets/images/greeting.jpg'),
                                         fit: BoxFit.cover
                                     )
                                 ),
                                 margin: EdgeInsets.all(12),
                                 padding: EdgeInsets.all(10),

                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Container(
                                       child: Text(greeting_message,
                                         style: TextStyle(
                                             color: Colors.deepPurpleAccent,
                                             fontSize: 20,
                                             fontWeight: FontWeight.bold),)
                                   ),
                                   SizedBox(height: 10,),
                                   Container(
                                       child: Text(auth.user.name,
                                         style: TextStyle(color: Colors.black54,
                                             fontSize: 16),
                                         textAlign: TextAlign.left,)
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                         ),
                         Container(
                           height: 130,
                           margin: EdgeInsets.symmetric(horizontal: 14),
                           child: Row(
                             children: [
                               Expanded(
                                 child: FadeAnimation(1.1, Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 8),
                                   height: 120,
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(20),
                                   ),
                                   child: Row(
                                     children: [
                                       Container(
                                         margin: EdgeInsets.only(left: 5),
                                         height: 60,
                                         width: MediaQuery
                                             .of(context)
                                             .size
                                             .width > 350 ? 60 : 40,
                                         decoration: BoxDecoration(
                                             image: DecorationImage(
                                                 image: AssetImage(
                                                     'assets/images/trip.png'),
                                                 fit: BoxFit.cover
                                             )
                                         ),
                                       ),
                                       Flexible(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment
                                               .start,
                                           mainAxisAlignment: MainAxisAlignment
                                               .center,
                                           children: [
                                             Container(
                                               margin: EdgeInsets.only(left: 5),
                                               decoration: BoxDecoration(
                                                 border: Border(
                                                   left: BorderSide(width: 4.0,
                                                       color: Colors.black12),
                                                 ),
                                                 color: Colors.white,
                                               ),
                                               child: Wrap(
                                                   children: [
                                                     Container(
                                                       padding: EdgeInsets.only(
                                                           left: 10, top: 0),
                                                       child: Text(
                                                           'Trips gone ',
                                                           style: TextStyle(
                                                               color: Colors
                                                                   .black54,
                                                               fontSize: 15)),
                                                     ),

                                                     Container(
                                                       padding: EdgeInsets.only(
                                                           left: 10, top: 5),
                                                       child: Icon(
                                                         Ionicons.ios_airplane,
                                                         size: 25,),
                                                     ),
                                                     Container(
                                                       padding: EdgeInsets.only(
                                                           left: 5, top: 5),
                                                       child: Text(
                                                         tripData == null
                                                             ? '0'
                                                             : tripData['tripTotal']
                                                             .toString(),
                                                         style: TextStyle(
                                                             color: Colors
                                                                 .purpleAccent,
                                                             fontSize: 20),),
                                                     ),
                                                   ]
                                               ),
                                             )
                                           ],
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                                 ),
                               ),
                               Expanded(child: FadeAnimation(1.4, Container(
                                 margin: EdgeInsets.symmetric(
                                     vertical: 10, horizontal: 8),
                                 height: 120,
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 child: Row(
                                   children: [
                                     Container(
                                       margin: EdgeInsets.only(left: 5),
                                       height: 60,
                                       width: MediaQuery
                                           .of(context)
                                           .size
                                           .width > 350 ? 60 : 40,
                                       decoration: BoxDecoration(
                                           image: DecorationImage(
                                               image: AssetImage(
                                                   'assets/images/sessions.jpg'),
                                               fit: BoxFit.cover
                                           )
                                       ),
                                     ),
                                     Flexible(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment
                                             .start,
                                         mainAxisAlignment: MainAxisAlignment
                                             .center,
                                         children: [
                                           Container(
                                             margin: EdgeInsets.only(left: 5),
                                             decoration: BoxDecoration(
                                               border: Border(
                                                 left: BorderSide(width: 4.0,
                                                     color: Colors.black12),
                                               ),
                                               color: Colors.white,
                                             ),
                                             child: Wrap(
                                                 children: [
                                                   Container(
                                                     padding: EdgeInsets.only(
                                                         left: 10, top: 0),
                                                     child: Text('Sessions ',
                                                         style: TextStyle(
                                                             color: Colors
                                                                 .black54,
                                                             fontSize: 15)),
                                                   ),
                                                   Container(
                                                     padding: EdgeInsets.only(
                                                         left: 10, top: 5),
                                                     child: Icon(
                                                       Ionicons.ios_people,
                                                       size: 25,),
                                                   ),
                                                   Container(
                                                     padding: EdgeInsets.only(
                                                         left: 5, top: 5),
                                                     child: Text(
                                                       sessionData == null
                                                           ? '0'
                                                           : sessionData['SessionsTotal']
                                                           .toString(),
                                                       style: TextStyle(
                                                           color: Colors
                                                               .purpleAccent,
                                                           fontSize: 20),),
                                                   ),
                                                 ]
                                             ),
                                           )
                                         ],
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                               ),)

                             ],
                           ),
                         ),

                       ],
                     ),
                   ),
                   FadeAnimation(1.7, Container(
                     padding: EdgeInsets.only(top: 20),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(
                             padding: EdgeInsets.only(left: 20),
                             child: Text('My Field Trips', style: TextStyle(
                                 color: Colors.deepPurple, fontSize: 18),
                               textAlign: TextAlign.left,)),
                         Container(
                           padding: EdgeInsets.only(right: 20),
                           width: MediaQuery
                               .of(context)
                               .size
                               .width > 350 ? 120 : 100,
                           height: MediaQuery
                               .of(context)
                               .size
                               .width > 350 ? 40 : 30,
                           child: FloatingActionButton(
                             heroTag: "btn1",
                             backgroundColor: Colors.deepPurpleAccent,
                             child: Text('See All', style: TextStyle(
                                 color: Colors.white, fontSize: MediaQuery
                                 .of(context)
                                 .size
                                 .width > 350 ? 14 : 12)),
                             isExtended: true,
                             onPressed: () {
                               Navigator.push(
                                   context,
                                   new MaterialPageRoute(
                                       builder: (context) => Trips())
                               );
                             },
                           ),
                         ),
                       ],
                     ),
                   ),
                   ),
                   FadeAnimation(2.0,
                       Container(
                         margin: EdgeInsets.symmetric(vertical: 10,
                             horizontal: 20),
                         width: double.infinity,
                         height: 100,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(15),
                           color: Colors.white,
                           boxShadow: [
                             BoxShadow(
                               color: Colors.grey.withOpacity(0.5),
                               spreadRadius: 5,
                               blurRadius: 7,
                               offset: Offset(
                                   0, 3), // changes position of shadow
                             ),
                           ],
                         ),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Week",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Total KM",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(tripData == null
                                               ? '0'
                                               : tripData['tripsThisWeek']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Month",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Total KM",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(tripData == null
                                               ? '0'
                                               : tripData['tripsThisMonth']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Year",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Total KM",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(tripData == null
                                               ? '0'
                                               : tripData['tripsThisYear']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                           ],
                         ),
                       )),
                   FadeAnimation(2.3, Container(
                     padding: EdgeInsets.only(top: 20),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(
                             padding: EdgeInsets.only(left: 20),
                             child: Text('My Field Sessions', style: TextStyle(
                                 color: Colors.deepPurple, fontSize: 18),
                               textAlign: TextAlign.left,)),
                         Container(
                           padding: EdgeInsets.only(right: 20),
                           width: MediaQuery
                               .of(context)
                               .size
                               .width > 350 ? 120 : 100,
                           height: MediaQuery
                               .of(context)
                               .size
                               .width > 350 ? 40 : 30,
                           child: FloatingActionButton(
                             heroTag: "btn2",
                             backgroundColor: Colors.deepPurpleAccent,
                             child: Text('See all', style: TextStyle(
                                 color: Colors.white, fontSize: MediaQuery
                                 .of(context)
                                 .size
                                 .width > 350 ? 14 : 12)),
                             isExtended: true,
                             onPressed: () {
                               Navigator.push(
                                   context,
                                   new MaterialPageRoute(
                                       builder: (context) => Sessions())
                               );
                             },
                           ),
                         ),
                       ],
                     ),
                   ),
                   ),
                   FadeAnimation(2.0,
                       Container(
                         margin: EdgeInsets.symmetric(vertical: 10,
                             horizontal: 20),
                         width: double.infinity,
                         height: 100,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(15),
                           color: Colors.white,
                           boxShadow: [
                             BoxShadow(
                               color: Colors.grey.withOpacity(0.5),
                               spreadRadius: 5,
                               blurRadius: 7,
                               offset: Offset(
                                   0, 3), // changes position of shadow
                             ),
                           ],
                         ),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Week",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Sessions",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(sessionData == null
                                               ? '0'
                                               : sessionData['SessionThisWeek']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Month",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Sessions",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(sessionData == null
                                               ? '0'
                                               : sessionData['SessionThisMonth']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                             Expanded(
                                 child: Container(
                                   margin: EdgeInsets.symmetric(
                                       vertical: 10, horizontal: 10),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Color(0xff4e54c8),
                                   ),
                                   child: Column(
                                     children: [
                                       Container(
                                           padding: EdgeInsets.only(top: 10),
                                           child: Text("This Year",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 16 : 12,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 1),
                                           child: Text("Sessions",
                                               style: TextStyle(
                                                 color: Colors.white70,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .width > 350 ? 12 : 10,))
                                       ),
                                       Container(
                                           padding: EdgeInsets.only(top: 10,),
                                           child: Text(sessionData == null
                                               ? '0'
                                               : sessionData['SessionThisYear']
                                               .toString(), style: TextStyle(
                                             color: Colors.white,
                                             fontSize: MediaQuery
                                                 .of(context)
                                                 .size
                                                 .width > 350 ? 18 : 15,))
                                       )
                                     ],
                                   ),
                                 )
                             ),
                           ],
                         ),
                       )),
                 ],
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
    );
  }

   logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    var response = await CallApi().logOut('logout',token);
    var body = json.decode(response.body);

    print(body['success']);
    if(body['success']){
      localStorage.remove('user');
      localStorage.remove('token');

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => Splash()));
    }
  }

  Future getApiTripData () async {
    final response = await TripApi().tripCounts();
    print('print from api trip');
    setState(() {
      tripData = response;
    });
  }

  Future getLocalTripData() async {
    String filename = 'tripData.json';
    var dir = await getTemporaryDirectory();
    File file =  File(dir.path + "/" + filename);
    if(file.existsSync()){
      final data = file.readAsStringSync();
      final res = json.decode(data);
      print('print from local trip');
      setState(() {
        tripData = res;
      });
    }
  }

  Future getApiSessionData() async{
    final response = await SessionApi().sessionCounts();
    print('print from api');
    setState(() {
      sessionData = response;
    });
  }

  Future getLocalSessionData() async {
    String filename = 'sessionsCounts.json';
    var dir = await getTemporaryDirectory();
    File file =  File(dir.path + "/" + filename);
    if(file.existsSync()){
      final data = file.readAsStringSync();
      final res = json.decode(data);
      print('print from local');
      setState(() {
        sessionData = res;
      });
    }
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        await getApiSessionData();
        await getApiTripData();
        setState(() {
          _connectionStatus = result.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have active wifi connection',textAlign: TextAlign.center,),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case ConnectivityResult.mobile:
        await getApiSessionData();
        await getApiTripData();
        setState(() {
          _connectionStatus = result.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have active mobile internet connection',textAlign: TextAlign.center,),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case ConnectivityResult.none:
       await getLocalSessionData();
       await getLocalTripData();
        setState(() {
          _connectionStatus = result.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device not connected to the internet',textAlign: TextAlign.center,),
            backgroundColor: Colors.red,
          ),
        );
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
    setState(() {
      _loading = false;
    });
  }
}
