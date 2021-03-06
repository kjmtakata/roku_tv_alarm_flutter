import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rokutvalarmflutter/main.dart';
import 'package:rokutvalarmflutter/models/alarms.dart';
import 'package:rokutvalarmflutter/models/alarm.dart';
import 'package:rokutvalarmflutter/models/device.dart';
import 'package:rokutvalarmflutter/screens/devices.dart';

class AlarmPage extends StatelessWidget {
  static const routeName = '/alarm';

  @override
  Widget build(BuildContext context) {
    AlarmsModel alarmsModel = Provider.of<AlarmsModel>(context, listen: false);
    Alarm alarm =
        alarmsModel.getById(ModalRoute.of(context).settings.arguments);
    return AlarmStatefulWidget(alarm);
  }
}

class AlarmStatefulWidget extends StatefulWidget {
  final Alarm alarm;

  AlarmStatefulWidget(this.alarm);

  @override
  AlarmStatefulWidgetState createState() {
    return AlarmStatefulWidgetState(alarm);
  }
}

class AlarmStatefulWidgetState extends State<AlarmStatefulWidget> {
  Alarm alarm;
  TimeOfDay alarmTime = TimeOfDay.now();
  Device device;
  final channelController = TextEditingController();
  Map<int, bool> isSelectedDay = <int, bool>{
    DateTime.sunday: false,
    DateTime.monday: false,
    DateTime.tuesday: false,
    DateTime.wednesday: false,
    DateTime.thursday: false,
    DateTime.friday: false,
    DateTime.saturday: false,
  };

  AlarmStatefulWidgetState(Alarm alarm) {
    this.alarm = alarm;

    if (alarm != null) {
      alarmTime = alarm.time;
      device = new Device(alarm.deviceUsn, alarm.deviceName);
      channelController.text = alarm.channel;
      isSelectedDay = alarm.getDayMap();
    }
  }

  void toggleIsSelectedDay(int day) {
    setState(() {
      isSelectedDay[day] = !isSelectedDay[day];
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${alarm == null ? 'Add' : 'Edit'} Alarm'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              AlarmsModel alarmsModel =
                  Provider.of<AlarmsModel>(context, listen: false);
              int alarmId =
                  this.alarm != null ? this.alarm.id : alarmsModel.getAlarmId();
              Alarm alarm = new Alarm(alarmId, alarmTime, device.usn,
                  device.name, channelController.text, isSelectedDay);
              if (this.alarm == null) {
                print("add alarm");
                alarmsModel.add(alarm);
              } else {
                print("update alarm");
                alarmsModel.update(alarm);
              }

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
                if (timeOfDay != null) {
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
            subtitle: Text(device?.name ?? "Not Selected"),
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
          launchChannel(device.usn, device.name, channelController.text);
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
