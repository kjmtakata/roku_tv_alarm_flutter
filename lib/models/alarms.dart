import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rokutvalarmflutter/main.dart';

import 'alarm.dart';

class AlarmsModel with ChangeNotifier {
  List<Alarm> alarms = [];

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    alarms.clear();
    await prefs.reload();
    for(String key in prefs.getKeys()) {
      alarms.add(Alarm.fromJson(jsonDecode(prefs.getString(key))));
    }
    notifyListeners();
  }

  void add(Alarm alarm) async {
    DateTime now = DateTime.now();

    DateTime alarmDateTime = DateTime(now.year, now.month,
        now.day, alarm.time.hour, alarm.time.minute);
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(Duration(days: 1));
    }

    if (!alarm.isOneTime()) {
      alarmDateTime = alarm.getNextAlarmDateTime(alarmDateTime);
    }

    AndroidAlarmManager.oneShotAt(alarmDateTime, alarm.id, alarmCallback,
        exact: true, wakeup: true, rescheduleOnReboot: true).then((success) async {
      if (success) {
        alarms.add(alarm);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(alarm.id.toString(), jsonEncode(alarm));
        notifyListeners();
      } else {
        print("failed to create alarm");
      }
    });
  }

  Future<bool> remove(Alarm alarm) async {
    if (await AndroidAlarmManager.cancel(alarm.id)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(alarm.id.toString());
      alarms.remove(alarm);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Alarm getById(int id) => alarms.firstWhere((alarm) => alarm.id == id, orElse: () => null);

  Alarm getByPosition(int i) => this.alarms[i];

  int length() => this.alarms.length;

  int getAlarmId() {
    int alarmId;
    do {
      alarmId = Random().nextInt(pow(2, 31));
    } while (getById(alarmId) != null);

    return alarmId;
  }
}
