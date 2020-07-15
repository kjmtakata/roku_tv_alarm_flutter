import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rokutvalarmflutter/screens/devices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:upnp/upnp.dart";
import '../models/alarms.dart';
import '../models/alarm.dart';

class AlarmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Alarm'),
      ),
      body: AlarmPageForm(),
    );
  }
}

class AlarmPageForm extends StatefulWidget {

  @override
  AlarmPageState createState() {
    return AlarmPageState();
  }
}

class AlarmPageState extends State<AlarmPageForm> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay alarmTime = TimeOfDay.now();
  Device device;

  // The callback for our alarm
  static Future<void> alarmCallback(int alarmId) async {
    print('Alarm fired! alarmId: ' + alarmId.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(alarmId.toString());
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Pick Time'),
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: alarmTime,
              ).then((TimeOfDay timeOfDay) {
                setState(() {
                  alarmTime = timeOfDay;
                });
              });
            },
          ),
          Text(alarmTime.format(context)),
          RaisedButton(
            child: Text('Add Alarm'),
            onPressed: () {
              int alarmId = Random().nextInt(pow(2, 31));
              DateTime now = DateTime.now();
              DateTime alarmDateTime = DateTime(now.year, now.month,
                  now.day, alarmTime.hour, alarmTime.minute);
              AndroidAlarmManager.oneShotAt(alarmDateTime, alarmId, alarmCallback,
                  exact: true, wakeup: true).then((success) {
                if (success) {
                  Provider.of<AlarmsModel>(context, listen: false).add(
                    new Alarm(alarmId, alarmTime)
                  );
                  Navigator.pop(context);
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Alarm could not be set"),
                  ));
                }
              });
            },
          ),
          RaisedButton(
            child: Text("Discover Devices"),
            onPressed: () async {
              device = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevicesPage()),
              );
              setState(() {});
            }
          ),
          Text(device?.friendlyName ?? "Not Selected")
        ],
      ),
    );
  }
}

