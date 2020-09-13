import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rokutvalarmflutter/screens/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnp/upnp.dart';

import 'package:rokutvalarmflutter/models/alarm.dart';
import 'package:rokutvalarmflutter/models/alarms.dart';
import 'package:rokutvalarmflutter/screens/alarms.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

var platformChannelSpecifics = NotificationDetails(
    AndroidNotificationDetails(
        'general', 'General', 'General Notifications Category'),
    IOSNotificationDetails());

void showNotification(String deviceName, String channel, {String body}) {
  flutterLocalNotificationsPlugin.show(
    0,
    'Launching $deviceName to channel $channel',
    body,
    platformChannelSpecifics,
  );
}

Future<void> launchChannel(
    String deviceUsn, String deviceName, String channel) async {
  try {
    var discoverer = new DeviceDiscoverer();
    await discoverer.start(ipv6: false);
    discoverer.quickDiscoverClients(query: "roku:ecp").listen((event) async {
      if (event.usn == deviceUsn) {
        String deviceUrl = event.location;
        discoverer.stop();
        http.Response response =
            await http.post("${deviceUrl}launch/tvinput.dtv?ch=$channel");
        showNotification(
          deviceName,
          channel,
          body: response.statusCode != 200
              ? "Failed with response code ${response.statusCode}"
              : null,
        );
      }
    });
  } catch (err) {
    showNotification(deviceName, channel, body: err.toString());
  }
}

Future<void> alarmCallback(int alarmId) async {
  print("firing alarmId: " + alarmId.toString());
  SharedPreferences pref = await SharedPreferences.getInstance();
  Alarm alarm = Alarm.fromJson(jsonDecode(pref.getString(alarmId.toString())));

  await launchChannel(alarm.deviceUsn, alarm.deviceName, alarm.channel);

  if (alarm.isOneTime()) {
    await pref.remove(alarm.id.toString());
  } else {
    DateTime now = DateTime.now();

    DateTime alarmDateTime = DateTime(
        now.year, now.month, now.day + 1, alarm.time.hour, alarm.time.minute);

    alarmDateTime = alarm.getNextAlarmDateTime(alarmDateTime);

    AndroidAlarmManager.oneShotAt(alarmDateTime, alarm.id, alarmCallback,
            exact: true, wakeup: true, rescheduleOnReboot: true)
        .then((success) async {
      if (!success) {
        flutterLocalNotificationsPlugin.show(
          1,
          'Failed to set next alarm to $alarmDateTime',
          "",
          platformChannelSpecifics,
        );
      }
    });
  }
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
      routes: {
        AlarmPage.routeName: (context) => AlarmPage(),
      },
    );
  }
}
