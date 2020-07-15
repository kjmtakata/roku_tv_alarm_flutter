import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "package:upnp/upnp.dart";

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Device> discoveredDevices = [];

  RefreshController _refreshController =
    RefreshController(initialRefresh: true);

  void _onRefresh() async {
    var discoverer = new DeviceDiscoverer();
    await discoverer.start(ipv6: false);
    this.discoveredDevices.clear();
    for(DiscoveredClient discoveredClient in await discoverer.discoverClients()) {
      this.discoveredDevices.add(await discoveredClient.getDevice());
    }
    _refreshController.refreshCompleted();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i < this.discoveredDevices.length) {
              return ListTile(
                title: Text(this.discoveredDevices[i].friendlyName),
                onTap: () => Navigator.pop(context),
              );
            }
            else {
              return null;
            }
          },
        )
      )
    );
  }
}