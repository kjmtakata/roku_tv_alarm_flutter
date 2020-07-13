import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm.dart';

class AlarmsModel with ChangeNotifier {
  bool isLoaded = false;
  List<Alarm> alarms = [];

  void load() async {
    if (!this.isLoaded) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for(String key in prefs.getKeys()) {
        this.alarms.add(Alarm.fromJson(jsonDecode(prefs.getString(key))));
      }
      this.isLoaded = true;
      notifyListeners();
    }
  }

  void add(Alarm alarm) async {
    this.alarms.add(alarm);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(alarm.hashCode.toString(), jsonEncode(alarm));
    notifyListeners();
  }

  Alarm getByPosition(int i) => this.alarms[i];

  int length() => this.alarms.length;
}
