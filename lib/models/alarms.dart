import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm.dart';

class AlarmsModel with ChangeNotifier {
  List<Alarm> alarms = [];

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.alarms.clear();
    await prefs.reload();
    for(String key in prefs.getKeys()) {
      this.alarms.add(Alarm.fromJson(jsonDecode(prefs.getString(key))));
      print("alarm: " + key);
    }
    notifyListeners();
    print("finished loading");
  }

  void add(Alarm alarm) async {
    this.alarms.add(alarm);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(alarm.id.toString(), jsonEncode(alarm));
    notifyListeners();
  }

  Alarm getByPosition(int i) => this.alarms[i];

  int length() => this.alarms.length;
}
