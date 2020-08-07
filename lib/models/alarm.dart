import 'package:flutter/material.dart';

class Alarm {
  int id;
  TimeOfDay time;
  String deviceUuid;
  String deviceName;
  String deviceUrl;
  String channel;
  int dayMap;

  Alarm(int id, TimeOfDay time, String deviceUuid, String deviceName,
      String deviceUrl, String channel, Map<int,bool> dayMap) {
    this.id = id;
    this.time = time;
    this.deviceUuid = deviceUuid;
    this.deviceName = deviceName;
    this.deviceUrl = deviceUrl;
    this.channel = channel;

    this.dayMap = 0;
    dayMap.forEach((key, value) {
      this.dayMap |= ((value ? 1 : 0) << key);
    });
  }

  Alarm.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        time = TimeOfDay(hour: json['hour'], minute: json['minute']),
        deviceUuid = json['device_uuid'],
        deviceName = json['device_name'],
        deviceUrl = json['device_url'],
        channel = json['channel'],
        dayMap = json['day_map'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': time.hour,
    'minute': time.minute,
    'device_uuid': deviceUuid,
    'device_name': deviceName,
    'device_url': deviceUrl,
    'channel': channel,
    'day_map': dayMap,
  };

  bool isDay(int day) => ((dayMap >> day) & 1) == 1;

  bool isOneTime() {
    for(int day = DateTime.monday; day <= DateTime.sunday; day++) {
      if(isDay(day)) {
        return false;
      }
    }
    return true;
  }

  DateTime getNextAlarmDateTime(DateTime dateTime) {
    int i;
    for (i = 0; i < 7; i++) {
      if (isDay(((dateTime.weekday-1 + i) % 7) + 1)) {
        break;
      }
    }
    dateTime = dateTime.add(Duration(days: i));
    return dateTime;
  }

  Map<int,bool> getDayMap() => <int,bool>{
    DateTime.sunday: isDay(DateTime.sunday),
    DateTime.monday: isDay(DateTime.monday),
    DateTime.tuesday: isDay(DateTime.tuesday),
    DateTime.wednesday: isDay(DateTime.wednesday),
    DateTime.thursday: isDay(DateTime.thursday),
    DateTime.friday: isDay(DateTime.friday),
    DateTime.saturday: isDay(DateTime.saturday),
  };
}