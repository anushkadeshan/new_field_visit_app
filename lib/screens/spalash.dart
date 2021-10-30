import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_field_visit_app/animations/fade_animation.dart';
import 'package:new_field_visit_app/screens/home.dart';
import 'package:new_field_visit_app/screens/login.dart';
import 'package:new_field_visit_app/screens/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Splash extends StatefulWidget {

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final String _url = 'https://bdsmis.eastus.cloudapp.azure.com/api/';

  @override
  void initState() {
    // TODO: implement initState
    _checkIfLoggedIn();
    super.initState();
  }

  _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Login()));
    } else {
      Future.delayed(Duration(milliseconds: 2500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          });
    }

    //Provider.of<Auth>(context, listen: false).tryToken(token: token);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill
                      )
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeAnimation(1, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-1.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(1.3, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-2.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(1.5, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/clock.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        child: FadeAnimation(1.6, Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("Welcome !", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(1.8, Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Image(image: AssetImage('assets/berendina.jpg'))
                      )),
                      SizedBox(height: 30,),
                      FadeAnimation(2, Container(
                        child: Center(
                          child: Text("Berendina Field Visits App", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),),
                        ),
                      )),
                      SizedBox(height: 40,),



                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  //setTimer(){
  //  Future.delayed(Duration(milliseconds: 2500), () {
  //    Navigator.pushReplacement(
  //      context,
  //      MaterialPageRoute(builder: (context) => Wrapper()),
  //    );
  //  });
  //}
}


