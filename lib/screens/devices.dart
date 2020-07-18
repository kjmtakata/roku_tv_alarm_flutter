import 'package:flutter/material.dart';
import "package:upnp/upnp.dart";

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  Map<String,Device> discoveredDevices = {};

  @override
  Widget build(BuildContext context) {
    var discoverer = new DeviceDiscoverer();
    discoverer.start(ipv6: false).then((value) {
      discoverer.quickDiscoverClients(query: "roku:ecp").listen((event) {
        if (mounted && !discoveredDevices.containsKey(event.usn)) {
          event.getDevice().then((device) {
            if (mounted) {
              setState(() {
                discoveredDevices.putIfAbsent(event.usn, () => device);
              });
            }
          });
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (i < this.discoveredDevices.length) {
            List<String> keys = discoveredDevices.keys.toList();
            Device device = discoveredDevices[keys[i]];
            return ListTile(
              title: Text(device.friendlyName),
              subtitle: Text("Model: ${device.modelName}"),
              onTap: () {
                discoverer.stop();
                Navigator.pop(context, device);
              },
            );
          }
          else {
            return null;
          }
        },
      )
    );
  }
}