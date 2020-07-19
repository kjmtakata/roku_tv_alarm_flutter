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
}