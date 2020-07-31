import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rokutvalarmflutter/main.dart';
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
  Map<int,bool> isSelectedDay = <int,bool>{
    DateTime.sunday: false,
    DateTime.monday: false,
    DateTime.tuesday: false,
    DateTime.wednesday: false,
    DateTime.thursday: false,
    DateTime.friday: false,
    DateTime.saturday: false,
  };

  void toggleIsSelectedDay(int day) {
    setState(() {
      isSelectedDay[day] = !isSelectedDay[day];
    });
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
              Provider.of<AlarmsModel>(context, listen: false).add(
                  new Alarm(alarmId, alarmTime, device.uuid,
                      device.friendlyName, device.url, channelController.text,
                      isSelectedDay)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DayOfWeekFilterWidget(
                label: "S",
                selected: isSelectedDay[DateTime.sunday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.sunday),
              ),
              DayOfWeekFilterWidget(
                label: "M",
                selected: isSelectedDay[DateTime.monday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.monday),
              ),
              DayOfWeekFilterWidget(
                label: "T",
                selected: isSelectedDay[DateTime.tuesday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.tuesday),
              ),
              DayOfWeekFilterWidget(
                label: "W",
                selected: isSelectedDay[DateTime.wednesday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.wednesday),
              ),
              DayOfWeekFilterWidget(
                label: "T",
                selected: isSelectedDay[DateTime.thursday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.thursday),
              ),
              DayOfWeekFilterWidget(
                label: "F",
                selected: isSelectedDay[DateTime.friday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.friday),
              ),
              DayOfWeekFilterWidget(
                label: "S",
                selected: isSelectedDay[DateTime.saturday],
                onSelected: (_) => toggleIsSelectedDay(DateTime.saturday),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          launchChannel(device.friendlyName, device.url, channelController.text);
        },
        label: Text("Test"),
      ),
    );
  }
}

class DayOfWeekFilterWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final onSelected;

  DayOfWeekFilterWidget({this.label, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilterChip(
        label: Text(label),
        showCheckmark: false,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}