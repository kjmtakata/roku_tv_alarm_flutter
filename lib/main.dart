import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/alarms.dart';
import 'models/alarms.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AlarmsModel(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roku TV Alarm',
      theme: ThemeData(),
      home: AlarmsPage(),
    );
  }
}