import 'package:flutter/material.dart';
import 'alarm.dart';

class AlarmsModel with ChangeNotifier {
  List<Alarm> alarms = [];

  void add(Alarm alarm) {
    this.alarms.add(alarm);
    notifyListeners();
  }

  List<Alarm> getAll() {
    return this.alarms;
  }

  Alarm getByPosition(int i) {
    return this.alarms[i];
  }

  int length() {
    return this.alarms.length;
  }
}
