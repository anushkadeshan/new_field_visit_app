import 'package:flutter/material.dart';
import 'package:new_field_visit_app/screens/session/time_provider.dart';
import 'package:new_field_visit_app/screens/spalash.dart';
import 'package:provider/provider.dart';

import 'auth_provider/authProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDS Field Visits',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
    );
  }
}

