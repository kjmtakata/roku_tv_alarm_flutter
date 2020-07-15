import 'package:flutter/material.dart';

class Alarm {
  final int id;
  final TimeOfDay time;

  Alarm(this.id, this.time);

  Alarm.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        time = TimeOfDay(hour: json['hour'], minute: json['minute']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': time.hour,
    'minute': time.minute
  };
}