import 'package:flutter/material.dart';

class Alarm {
  TimeOfDay time;

  Alarm(this.time);

  String toString() {
    return this.time.toString();
  }
}