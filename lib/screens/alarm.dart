import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rokutvalarmflutter/screens/devices.dart';
import 'package:rokutvalarmflutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:upnp/upnp.dart" as upnp;
import 'package:http/http.dart' as http;
import '../models/alarms.dart';
import '../models/alarm.dart';

class AlarmPage extends StatefulWidget {
  @override
  AlarmPageState createState() {
    return AlarmPageState();
  }
}

class AlarmPageState extends State<AlarmPage> {
  TimeOfDay alarmTime = TimeOfDay.now();
  upnp.Device device;
  final channelController = TextEditingController();

  // The callback for our alarm
  static Future<void> alarmCallback(int alarmId) async {
    print("firing alarmId: " + alarmId.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString(alarmId.toString()));
    Alarm alarm = Alarm.fromJson(jsonDecode(pref.getString(alarmId.toString())));
    flutterLocalNotificationsPlugin.show(
      0,
      'Activating Roku TV',
      'Turning on ${alarm.deviceName} to channel ${alarm.channel}',
      platformChannelSpecifics,
    );

    await http.post("${alarm.deviceUrl}launch/tvinput.dtv?ch=${alarm.channel}");

    await pref.remove(alarmId.toString());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              int alarmId = Random().nextInt(pow(2, 31));
              DateTime now = DateTime.now();
              DateTime alarmDateTime = DateTime(now.year, now.month,
                  now.day, alarmTime.hour, alarmTime.minute);
              AndroidAlarmManager.oneShotAt(alarmDateTime, alarmId, alarmCallback,
                  exact: true, wakeup: true).then((success) {
                if (success) {
                  Provider.of<AlarmsModel>(context, listen: false).add(
                      new Alarm(alarmId, alarmTime, device.uuid,
                          device.friendlyName, device.url, channelController.text)
                  );
                  Navigator.pop(context);
                } else {
                  print("failed to create alarm");
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Time'),
            subtitle: Text(alarmTime.format(context)),
            onTap: () {
              showTimePicker(
                context: context,
                initialTime: alarmTime,
              ).then((TimeOfDay timeOfDay) {
                if(timeOfDay != null) {
                  setState(() {
                    alarmTime = timeOfDay;
                  });
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.tv),
            title: const Text('Roku Device'),
            subtitle: Text(device?.friendlyName ?? "Not Selected"),
            onTap: () async {
              device = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevicesPage()),
              );
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.dialpad),
            title: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Channel",
              ),
              controller: channelController,
            ),
          ),
        ],
      ),
    );
  }
}

