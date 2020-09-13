import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:rokutvalarmflutter/models/alarm.dart';
import 'package:rokutvalarmflutter/models/alarms.dart';
import 'package:rokutvalarmflutter/screens/alarm.dart';

enum AlarmAction { delete }

class AlarmsPage extends StatefulWidget {
  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
  }

  void _onRefresh() async {
    Provider.of<AlarmsModel>(context, listen: false).load();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarms'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: (context, i) {
            AlarmsModel alarms = Provider.of<AlarmsModel>(context);
            if (i < alarms.length()) {
              Alarm alarm = alarms.getByPosition(i);
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AlarmPage.routeName,
                    arguments: alarm.id,
                  );
                },
                child: Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(alarm.time.format(context)),
                        subtitle: Text("Channel: " +
                            (alarm.channel ?? "") +
                            " | " +
                            (alarm.deviceName ?? "")),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => <PopupMenuItem<AlarmAction>>[
                            new PopupMenuItem<AlarmAction>(
                              child: const Text('Delete'),
                              value: AlarmAction.delete,
                            ),
                          ],
                          onSelected: (action) {
                            if (action == AlarmAction.delete) {
                              alarms.remove(alarm);
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DayOfWeekFilterWidget(
                            label: "S",
                            selected: alarm.isDay(DateTime.sunday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "M",
                            selected: alarm.isDay(DateTime.monday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "T",
                            selected: alarm.isDay(DateTime.tuesday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "W",
                            selected: alarm.isDay(DateTime.wednesday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "T",
                            selected: alarm.isDay(DateTime.thursday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "F",
                            selected: alarm.isDay(DateTime.friday),
                          ),
                          DayOfWeekFilterWidget(
                            label: "S",
                            selected: alarm.isDay(DateTime.saturday),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return null;
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AlarmPage.routeName,
          );
        },
        tooltip: 'Add Alarm',
        child: Icon(Icons.add_alarm),
      ),
    );
  }
}
