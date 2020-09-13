import 'package:flutter/material.dart';
import 'package:upnp/upnp.dart' as upnp;

import 'package:rokutvalarmflutter/models/device.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  Map<String, upnp.Device> discoveredDevices = {};

  @override
  Widget build(BuildContext context) {
    var discoverer = new upnp.DeviceDiscoverer();
    discoverer.start(ipv6: false).then((value) {
      discoverer.quickDiscoverClients(query: "roku:ecp").listen((event) {
        if (mounted && !discoveredDevices.containsKey(event.usn)) {
          print(event);
          event.getDevice().then((device) {
            if (mounted) {
              print(device.deviceElement);
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
        title: const Text('Devices'),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (i < this.discoveredDevices.length) {
            List<String> keys = discoveredDevices.keys.toList();
            String usn = keys[i];
            upnp.Device upnpDevice = discoveredDevices[usn];
            return ListTile(
              title: Text(upnpDevice.friendlyName),
              subtitle: Text("Model: ${upnpDevice.modelName}"),
              onTap: () {
                discoverer.stop();
                Device device = new Device(usn, upnpDevice.friendlyName);
                Navigator.pop(context, device);
              },
            );
          } else {
            return null;
          }
        },
      ),
    );
  }
}
