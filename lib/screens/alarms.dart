import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarms.dart';
import '../models/alarm.dart';
import 'alarm.dart';

class AlarmsPage extends StatefulWidget {
  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Alarms'),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          AlarmsModel alarms = Provider.of<AlarmsModel>(context);
          if (i < alarms.length()) {
            Alarm alarm = alarms.getByPosition(i);
            return ListTile(
              title: Text(
                alarm.toString(),
              ),
            );
          }
          else {
            return null;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlarmPage()),
          );
        },
        tooltip: 'Add Alarm',
        child: Icon(Icons.add_alarm),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
