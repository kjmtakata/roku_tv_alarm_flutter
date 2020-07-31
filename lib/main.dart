import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/alarms.dart';
import 'models/alarms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/alarm.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

var platformChannelSpecifics = NotificationDetails(
    AndroidNotificationDetails('general', 'General', 'General Notifications Category'),
    IOSNotificationDetails()
);

void showNotification(String deviceName, String channel, {String body}) {
  flutterLocalNotificationsPlugin.show(
    0,
    'Launching $deviceName to channel $channel',
    body,
    platformChannelSpecifics,
  );
}

Future<void> launchChannel(String deviceName, String deviceUrl, String channel) async {
  try {
    http.Response response = await http.post(
        "${deviceUrl}launch/tvinput.dtv?ch=$channel");
    showNotification(deviceName, channel, body: response.statusCode != 200 ?
      "Failed with response code ${response.statusCode}" : "");
  } catch (err) {
    showNotification(deviceName, channel, body: err.toString());
  }
}

Future<void> alarmCallback(int alarmId) async {
  print("firing alarmId: " + alarmId.toString());
  SharedPreferences pref = await SharedPreferences.getInstance();
  Alarm alarm = Alarm.fromJson(jsonDecode(pref.getString(alarmId.toString())));

  await launchChannel(alarm.deviceName, alarm.deviceUrl, alarm.channel);

  await pref.remove(alarmId.toString());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettings = InitializationSettings(
      AndroidInitializationSettings('@mipmap/ic_launcher'),
      IOSInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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