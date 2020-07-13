import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarms.dart';
import '../models/alarm.dart';

class AlarmPage extends StatefulWidget {

  @override
  AlarmPageState createState() {
    return AlarmPageState();
  }
}

class AlarmPageState extends State<AlarmPage> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay alarmTime = TimeOfDay.now();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Alarm'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Pick Time'),
              onPressed: () {
                Future<TimeOfDay> future = showTimePicker(
                  context: context,
                  initialTime: alarmTime,
                );
                future.then((TimeOfDay timeOfDay) {
                  setState(() {
                    alarmTime = timeOfDay;
                  });
                });
              },
            ),
            Text(alarmTime.toString()),
            RaisedButton(
              child: Text('Add Alarm'),
              onPressed: () {
                Provider.of<AlarmsModel>(context, listen: false).add(
                    new Alarm(alarmTime)
                );
                Navigator.pop(context);
              },
            )
          ],
        ),
      )
    );
  }
}

