import 'package:flutter/material.dart';

class Alarm {
  final int id;
  final TimeOfDay time;
  final String deviceUuid;
  final String deviceName;
  final String deviceUrl;
  final String channel;

  Alarm(this.id, this.time, this.deviceUuid, this.deviceName,
      this.deviceUrl, this.channel);

  Alarm.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        time = TimeOfDay(hour: json['hour'], minute: json['minute']),
        deviceUuid = json['device_uuid'],
        deviceName = json['device_name'],
        deviceUrl = json['device_url'],
        channel = json['channel'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': time.hour,
    'minute': time.minute,
    'device_uuid': deviceUuid,
    'device_name': deviceName,
    'device_url': deviceUrl,
    'channel': channel,
  };
}