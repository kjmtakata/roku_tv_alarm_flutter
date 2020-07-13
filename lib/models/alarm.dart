import 'dart:convert';

import 'package:flutter/material.dart';

class Alarm {
  final TimeOfDay time;

  Alarm(this.time);

  Alarm.fromJson(Map<String, dynamic> json)
    : time = TimeOfDay(hour: json['hour'], minute: json['minute']);

  Map<String, dynamic> toJson() => {
    'hour': time.hour,
    'minute': time.minute
  };
}