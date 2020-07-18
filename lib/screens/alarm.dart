import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rokutvalarmflutter/screens/devices.dart';
import "package:upnp/upnp.dart" as upnp;
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              int alarmId = Random().nextInt(pow(2, 31));
              Provider.of<AlarmsModel>(context, listen: false).add(
                  new Alarm(alarmId, alarmTime, device.uuid,
                      device.friendlyName, device.url, channelController.text)
              );
              Navigator.pop(context);
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

