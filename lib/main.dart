import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/alarms.dart';
import 'models/alarms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

var platformChannelSpecifics = NotificationDetails(
    AndroidNotificationDetails('general', 'General', 'General Notifications Category'),
    IOSNotificationDetails()
);

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