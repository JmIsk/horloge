import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solar_calculator/solar_calculator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';
import 'package:spa/spa.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

void main() {
  runApp(MyApp());
}

String fmtHHMM(int hours, int mins) =>
    '${hours.toString().padLeft(2)}:${mins.toString().padLeft(2, '0')}';

int displayTime() {
  return Instant.fromDateTime(DateTime.now()).time.inMilliseconds;
}

int solarTime() {
  var now = DateTime.now();
  var aaa = spaCalculate(
          SPAParams(time: now, longitude: 2.332775, latitude: 48.908875))
      .sunTransit;
  int hours = aaa.floor();
  int mins = ((aaa - aaa.floor()) * 60).floor();
  var solarNoon =
      Instant.fromDateTime(DateTime(now.year, now.month, now.day, hours, mins));
  var noon = DateTime(now.year, now.month, now.day, 12, 00);
  var diff = Instant.fromDateTime(noon).time - solarNoon.time;
  var solarTime = Instant.fromDateTime(DateTime.now()).add(diff);
  return solarTime.time.inMilliseconds;
}

String displayResult(int a) {
  var now = DateTime.now();
  var calcul = spaCalculate(
      SPAParams(time: now, longitude: 2.332775, latitude: 48.908875));
  if (a == 1)
    return fmtHHMM(
        calcul.sunTransit.floor(), (calcul.sunTransit * 60).floor() % 60);
  if (a == 2)
    return fmtHHMM(calcul.sunrise.floor(), (calcul.sunrise * 60).floor() % 60);
  if (a == 3)
    return fmtHHMM(calcul.sunset.floor(), (calcul.sunset * 60).floor() % 60);
  else
    return 'Problem';
}

int displaySolarTime() {
  Instant solarTime;

  var solarNoon = SolarCalculator(
          Instant.fromDateTime(DateTime.now(), timeZoneOffset: 2),
          48.908875,
          2.332775,
          2)
      .sunTransitTime;
  var noon = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0, 0);
  var diff = Instant.fromDateTime(noon).time - solarNoon.time;

  solarTime = Instant.fromDateTime(DateTime.now()).add(diff);

  return solarTime.time.inMilliseconds;
}

String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  var milli = (milliseconds % 1000).toString().padLeft(3, '0');

  return "$hours:$minutes:$seconds:$milli";
}

String formatTime2(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');

  return "$hours:$minutes:$seconds";
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Horloge', home: StopwatchPage());
  }
}

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Timer _timer;
  bool _checkBox = false;

  final _isHours = true;

  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);

  final StopWatchTimer _stopWatchTimerDown =
      StopWatchTimer(mode: StopWatchMode.countDown, presetMillisecond: 60000);

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {});
    });

    _stopWatchTimer.setPresetTime(mSec: 0000);
    _stopWatchTimerDown.setPresetTime(mSec: 60000);
  }

  @override
  void dispose() async {
    _timer.cancel();
    super.dispose();
    await _stopWatchTimer.dispose();
    await _stopWatchTimerDown.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.timer)),
                Tab(icon: Icon(Icons.access_alarm)),
              ],
            ),
            title: Text('Horloge'),
          ),
          body: TabBarView(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          Container(width: 10),
                          Text(
                            'Local time: ' +
                                formatTime2(displayTime()).toString(),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          Container(width: 10),
                          Text(
                            'UTC time: ' +
                                formatTime2(
                                    Instant.fromDateTime(DateTime.now().toUtc())
                                        .time
                                        .inMilliseconds),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.yellowAccent),
                          Container(width: 10),
                          Text(
                            'Solar noon: ' + displayResult(1),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.yellow,
                          ),
                          Container(width: 10),
                          Text(
                            'Solar time: ' + formatTime2(solarTime()),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.yellow),
                          Container(width: 10),
                          Text(
                            'Sunrise: ' + displayResult(2),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange),
                          Container(width: 10),
                          Text(
                            'Sunset: ' + displayResult(3),
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
              Column(
                children: [
                  Center(
                      child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: _stopWatchTimer.rawTime.value,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime =
                          StopWatchTimer.getDisplayTime(value, hours: _isHours);
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      );
                    },
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                        },
                        child: Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                        },
                        child: Text('Stop'),
                      ),
                      ElevatedButton(
                        child: Text('Reset'),
                        onPressed: () async {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        },
                      ),
                      ElevatedButton(
                        child: Text('Lap'),
                        onPressed: () async {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.lap);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      height: 150,
                      margin: const EdgeInsets.all(8),
                      child: StreamBuilder<List<StopWatchRecord>>(
                        stream: _stopWatchTimer.records,
                        initialData: _stopWatchTimer.records.value,
                        builder: (context, snap) {
                          final value = snap.data;
                          if (value.isEmpty) {
                            return Container();
                          }
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut);
                          });
                          //print('Listen records. $value');
                          return ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              final data = value[index];
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${index + 1} ${data.displayTime}',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  )
                                ],
                              );
                            },
                            itemCount: value.length,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () async {
                            int count = _stopWatchTimerDown.minuteTime.value;
                            if (count > 0)
                              _stopWatchTimerDown
                                  .setPresetMinuteTime(count - 1);
                          }),
                      Center(
                        child: StreamBuilder<int>(
                          stream: _stopWatchTimerDown.rawTime,
                          initialData: _stopWatchTimerDown.rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                                hours: _isHours);
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    displayTime,
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.add_circle_outlined),
                          onPressed: () async {
                            int count = _stopWatchTimerDown.minuteTime.value;
                            _stopWatchTimerDown.setPresetMinuteTime(count + 1);
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _checkBox,
                        onChanged: (value) {
                          var secs = _stopWatchTimerDown.secondTime.value;

                          setState(() {
                            _checkBox = !_checkBox;
                          });
                          if (_checkBox == true) {
                            Timer(Duration(seconds: secs), () {
                              _stopWatchTimerDown.onExecute
                                  .add(StopWatchExecute.reset);
                              _stopWatchTimerDown.onExecute
                                  .add(StopWatchExecute.start);
                            });
                          }
                        },
                      ),
                      Text('Auto-restart'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _stopWatchTimerDown.onExecute
                              .add(StopWatchExecute.start);
                        },
                        child: Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          _stopWatchTimerDown.onExecute
                              .add(StopWatchExecute.stop);
                        },
                        child: Text('Stop'),
                      ),
                      ElevatedButton(
                        child: Text('Reset'),
                        onPressed: () async {
                          _stopWatchTimerDown.onExecute
                              .add(StopWatchExecute.reset);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
