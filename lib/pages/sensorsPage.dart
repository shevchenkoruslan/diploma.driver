import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'dart:math';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToSensorsArgs.dart';
import 'package:driver/arguments/passToTripAnalysArgs.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/pages/tripAnalysPage.dart';
import 'package:driver/services/calculate.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SensorsPage extends StatefulWidget {
  static const routeName = '/sensors';
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;
  List<double> _accelerometerXValues = <double>[];
  List<double> _accelerometerYValues = <double>[];
  List<double> _gyroscopeXValues = <double>[];
  List<double> _gyroscopeYValues = <double>[];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  List<Map<String, dynamic>> _data = <Map<String, dynamic>>[];
  Timer _timerToSave;
  int _secs = 0;
  int period = 500;
  int _weaving, _swerving, _suddenBraking, _fastUTurn;
  List<int> allTripAbnormal = [];
  DateTime startTime, endTime;
  bool _autoSave = false;

  int _convertValuesToPoints(int value) {
    if (value == 0)
      return 100;
    else if (value <= 2)
      return 90;
    else if (value <= 5)
      return 80;
    else if (value <= 7)
      return 70;
    else if (value <= 9)
      return 60;
    else if (value <= 11)
      return 50;
    else if (value <= 13)
      return 40;
    else if (value <= 15)
      return 30;
    else if (value <= 17)
      return 20;
    else if (value <= 19)
      return 10;
    else
      return 0;
  }

  int _getAverage() {
    return ((_convertValuesToPoints(_weaving) +
                _convertValuesToPoints(_swerving) +
                _convertValuesToPoints(_suddenBraking) +
                _convertValuesToPoints(_fastUTurn)) /
            4)
        .round();
  }

  void _saveDataToDB(args) {
    Firestore.instance.collection("statistics").document().setData({
      "uid": args.userId,
      "weaving": _convertValuesToPoints(_weaving),
      "swerving": _convertValuesToPoints(_swerving),
      "suddenBraking": _convertValuesToPoints(_suddenBraking),
      "fastUTurn": _convertValuesToPoints(_fastUTurn),
      "average": _getAverage(),
      "startTime": startTime,
      "endTime": endTime
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _timerToSave?.cancel();
    _accelerometerXValues = List();
    _accelerometerYValues = List();
    _gyroscopeXValues = List();
    _gyroscopeYValues = List();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _autoSave = prefs.getBool('autoSave') ?? false;
      });
    });
    _weaving = _swerving = _suddenBraking = _fastUTurn = 0;
    startTime = DateTime.now();
    _accelerometerXValues = List();
    _accelerometerYValues = List();
    _gyroscopeXValues = List();
    _gyroscopeYValues = List();
    allTripAbnormal = List();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _accelerometerXValues.add(roundDouble(event.x, 2));
        _accelerometerYValues.add(roundDouble(event.y, 2));
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        _gyroscopeXValues.add(roundDouble(event.x, 2));
        _gyroscopeYValues.add(roundDouble(event.y, 2));
      });
    }));
    // _streamSubscriptions
    //     .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   setState(() {
    //     _userAccelerometerValues = <double>[event.x, event.y, event.z];
    //   });
    // }));
    _timerToSave = Timer.periodic(Duration(milliseconds: period), (timer) {
      _secs += period;
      // print({
      //   "acc.x": _accelerometerValues[0],
      //   "acc.y": _accelerometerValues[1],
      //   "ori.x": _gyroscopeValues[0],
      //   "ori.y": _gyroscopeValues[1],
      //   "time": (_secs / 1000)
      // });
      _data.add({
        "acc.x": _accelerometerValues[0],
        "acc.y": _accelerometerValues[1],
        "ori.x": _gyroscopeValues[0],
        "ori.y": _gyroscopeValues[1],
        "time": (_secs / 1000)
      });
    });

    // print(_data);
    // _data = [
    //   {"acc.x": -0.1, "acc.y": 1.2, "ori.x": -10.0, "ori.y": -0.3, "time": 0},
    //   {"acc.x": -0.2, "acc.y": 1.1, "ori.x": -9.8, "ori.y": -0.5, "time": 0.5},
    //   {"acc.x": -0.1, "acc.y": 1.2, "ori.x": -9.9, "ori.y": -0.4, "time": 1},
    //   {"acc.x": -0.3, "acc.y": 1.1, "ori.x": -10.1, "ori.y": -0.3, "time": 1.5},
    //   {"acc.x": 2.5, "acc.y": 1.0, "ori.x": -10.2, "ori.y": -0.2, "time": 2},
    //   {"acc.x": 1.9, "acc.y": 1.9, "ori.x": -7.5, "ori.y": -0.3, "time": 2.5},
    //   {"acc.x": -9.7, "acc.y": -0.1, "ori.x": 2.3, "ori.y": 0.1, "time": 3},
    //   {"acc.x": 1.4, "acc.y": 1.4, "ori.x": -11.5, "ori.y": -0.1, "time": 3.5},
    //   {"acc.x": -1.9, "acc.y": 0.9, "ori.x": -9.0, "ori.y": -0.1, "time": 4},
    //   {"acc.x": -1.5, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 4.5},
    //   {"acc.x": -1.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 5},
    //   {"acc.x": -0.4, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 5.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 6},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 6.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 7},
    //   {"acc.x": -0.2, "acc.y": 0.1, "ori.x": -9.8, "ori.y": 0.0, "time": 7.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 8},
    //   {"acc.x": -2.0, "acc.y": 2.1, "ori.x": -6.0, "ori.y": -1.5, "time": 8.5},
    //   {"acc.x": -1.6, "acc.y": -0.8, "ori.x": -8.9, "ori.y": 0.0, "time": 9},
    //   {"acc.x": -0.5, "acc.y": -5.0, "ori.x": -13.0, "ori.y": 2.7, "time": 9.5},
    //   {"acc.x": -0.2, "acc.y": -4.0, "ori.x": -12.2, "ori.y": 1.4, "time": 10},
    //   {
    //     "acc.x": -0.1,
    //     "acc.y": -4.2,
    //     "ori.x": -12.4,
    //     "ori.y": 1.7,
    //     "time": 10.5
    //   },
    //   {"acc.x": 0.0, "acc.y": -4.0, "ori.x": -12.1, "ori.y": 1.6, "time": 11},
    //   {"acc.x": 0.1, "acc.y": -4.9, "ori.x": -13.5, "ori.y": 1.7, "time": 11.5},
    //   {"acc.x": 0.0, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 12},
    //   {"acc.x": -0.1, "acc.y": 0.1, "ori.x": -9.8, "ori.y": 0.0, "time": 12.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 13},
    // ];
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    final PassToSensorsArgs args = ModalRoute.of(context).settings.arguments;
    // final List<String> accelerometer =
    //     _accelerometerValues?.map((double v) => v.toStringAsFixed(2))?.toList();
    // final List<String> gyroscope =
    //     _gyroscopeValues?.map((double v) => v.toStringAsFixed(2))?.toList();
    // final List<String> userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(2))
    //     ?.toList();

    Oscilloscope oscilloscopeAccX = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 10.0,
      yAxisMin: -10.0,
      dataSet: _accelerometerXValues,
    );
    Oscilloscope oscilloscopeAccY = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.transparent,
      traceColor: Colors.red,
      yAxisMax: 10.0,
      yAxisMin: -10.0,
      dataSet: _accelerometerYValues,
    );
    Oscilloscope oscilloscopeOriX = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 5.0,
      yAxisMin: -5.0,
      dataSet: _gyroscopeXValues,
    );
    Oscilloscope oscilloscopeOriY = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.transparent,
      traceColor: Colors.red,
      yAxisMax: 5.0,
      yAxisMin: -5.0,
      dataSet: _gyroscopeYValues,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Warning"),
                  content: Text("Do you want to quit without saving?"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _timerToSave?.cancel();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text("Yes"),
                    ),
                    SizedBox(width: 10),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("No"),
                    ),
                  ],
                );
              }),
        ),
        title: Text(
          "Trip",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: _height * 0.024),
        ),
        backgroundColor: Color(0xFFbdbfbe),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 300,
                child: Stack(children: <Widget>[
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeAccX,
                  ),
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeAccY,
                  ),
                ]),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.green,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("X axis"),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.red,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("Y axis"),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 0.0),
            child: Text("Accelerometer"),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 300,
                child: Stack(children: <Widget>[
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeOriX,
                  ),
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeOriY,
                  ),
                ]),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.green,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("X axis"),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.red,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("Y axis"),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 0.0),
            child: Text("Gyroscope"),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            width: _width,
            child: SizedBox(
              height: 40.0,
              child: RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: _darkTheme ? Color(0xFFbdbfbe) : Color(0xFF669999),
                child: Text(
                  "STOP",
                  style: TextStyle(
                      fontSize: _height * 0.019,
                      color: _darkTheme ? Color(0xFF2a4848) : Colors.white,
                      fontFamily: "Palatino",
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  // print("Pressed");
                  // print("Autosave: $_autoSave");
                  _timerToSave?.cancel();
                  setState(() {
                    endTime = DateTime.now();
                  });
                  // writeDataToJSON(_data, args, startTime, endTime);
                  // _analysData();
                  _analysDataFromDB().then((_) {
                    if (_autoSave) {
                      _saveDataToDB(args);
                      showProfile(context, args);
                      // Navigator.pushNamed(context, TripAnalysPage.routeName,
                      //     arguments: PassToTripAnalysArgs(args.auth, args.userId,
                      //         _weaving, _swerving, _fastUTurn, _suddenBraking));
                    } else {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Warning"),
                              content: Text("Do you want to save trip?"),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    _timerToSave?.cancel();
                                    _saveDataToDB(args);
                                    Navigator.of(context).pop();
                                    showProfile(context, args);
                                    // Navigator.pushNamed(
                                    //     context, TripAnalysPage.routeName,
                                    //     arguments: PassToTripAnalysArgs(
                                    //         args.auth,
                                    //         args.userId,
                                    //         _weaving,
                                    //         _swerving,
                                    //         _fastUTurn,
                                    //         _suddenBraking));
                                  },
                                  child: Text("Yes"),
                                ),
                                SizedBox(width: 10),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showProfile(context, args);
                                    // Navigator.of(context).pop();
                                    // Navigator.pushNamed(
                                    //     context, TripAnalysPage.routeName,
                                    //     arguments: PassToTripAnalysArgs(
                                    //         args.auth,
                                    //         args.userId,
                                    //         _weaving,
                                    //         _swerving,
                                    //         _fastUTurn,
                                    //         _suddenBraking));
                                  },
                                  child: Text("No"),
                                ),
                              ],
                            );
                          });
                    }
                  });
                  // //////////////////////////////////////////////////////////////////////////////////////
                  // if (_autoSave) {
                  //   _saveDataToDB(args);
                  //   showProfile(context, args);
                  // } else {
                  //   showDialog(
                  //       context: context,
                  //       barrierDismissible: false,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: Text("Warning"),
                  //           content: Text("Do you want to save trip?"),
                  //           actions: <Widget>[
                  //             FlatButton(
                  //               onPressed: () {
                  //                 _timerToSave?.cancel();
                  //                 _saveDataToDB(args);
                  //                 Navigator.of(context).pop();
                  //                 showProfile(context, args);
                  //               },
                  //               child: Text("Yes"),
                  //             ),
                  //             SizedBox(width: 10),
                  //             FlatButton(
                  //               onPressed: () {
                  //                 Navigator.of(context).pop();
                  //                 showProfile(context, args);
                  //               },
                  //               child: Text("No"),
                  //             ),
                  //           ],
                  //         );
                  //       });
                  // }
                  // ////////////////////////////////////////////////
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  double mean(a, b) {
    return (a + b) / 2;
  }

  double stDeviation(a, b, mean) {
    return sqrt(pow((a - mean), 2) + pow((b - mean), 2));
  }

  Future<void> _analysData() async {
    print("Analys data");
    List<dynamic> _abnormalClassifications = [];
    List<Map<String, dynamic>> _smoothedData = <Map<String, dynamic>>[];

    _smoothedData = smoothingSMAUnknown(_data);

    bool startAbnormal = false;
    int abnormalBeginIndex = 0;
    int abnormal = 0;

    var _dataModels =
        json.decode(await rootBundle.loadString('models/behaviorModels.json'));
    for (var i = 1; i < _smoothedData.length; i++) {
      if (stDeviation(_smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"],
              mean(_smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"])) >
          0.3) {
        if (startAbnormal != true && i != _smoothedData.length - 1) {
          startAbnormal = true;
          abnormalBeginIndex = i - 1;
          print("Start i: $i");
        }
        if (i == _smoothedData.length - 1 && startAbnormal == true) {
          print("End i: $i");
          startAbnormal = false;
          abnormal += 1;
          _abnormalClassifications.add(classifyAbnormal(
              _smoothedData, _dataModels, abnormalBeginIndex, i));
        }
      } else if (startAbnormal == true && i == _smoothedData.length - 1) {
        print("End i: $i");
        startAbnormal = false;
        abnormal += 1;
        _abnormalClassifications.add(classifyAbnormal(
            _smoothedData, _dataModels, abnormalBeginIndex, i));
      } else if (startAbnormal == true) {
        if (stDeviation(
                _smoothedData[i]["acc.x"],
                _smoothedData[i + 1]["acc.x"],
                mean(
                    _smoothedData[i]["acc.x"], _smoothedData[i + 1]["acc.x"])) >
            0.23) {
          print("Continue");
        } else if (i != _smoothedData.length - 2 &&
            stDeviation(
                    _smoothedData[i + 1]["acc.x"],
                    _smoothedData[i + 2]["acc.x"],
                    mean(_smoothedData[i + 1]["acc.x"],
                        _smoothedData[i + 2]["acc.x"])) >
                0.23) {
          print("Continue");
        } else {
          print("End i: $i");
          startAbnormal = false;
          abnormal += 1;
          _abnormalClassifications.add(classifyAbnormal(
              _smoothedData, _dataModels, abnormalBeginIndex, i));
        }
      }
      if (_smoothedData[i]['time'] % 60 == 0 || i == _smoothedData.length - 1) {
        print("In 60");
        print("Abn in 60: $abnormal");
        allTripAbnormal.add(abnormal);
        abnormal = 0;
      }
    }

    if (_abnormalClassifications.length > 0) {
      for (var ab in _abnormalClassifications) {
        ab == "Weaving"
            ? _weaving++
            : ab == "Swerving"
                ? _swerving++
                : ab == "Fast U-turn" ? _fastUTurn++ : _suddenBraking++;
      }
      print("In analys");
      print("Weaving: $_weaving");
      print("Swerving: $_swerving");
      print("Fast: $_fastUTurn");
      print("Sudden: $_suddenBraking");
    }
  }

  Future<void> _analysDataFromDB() async {
    print("Analys data");
    List<dynamic> _abnormalClassifications = [];
    List<Map<String, dynamic>> _smoothedData = <Map<String, dynamic>>[];

    bool startAbnormal = false;
    int abnormalBeginIndex = 0;
    int abnormal = 0;

    var _dataModels =
        json.decode(await rootBundle.loadString('models/behaviorModels.json'));
    // print("DATA MODELS LENGTH: ${_dataModels.length}");
    _makeTemplate().then((d) {
      _smoothedData = smoothingSMAUnknown(d);

      for (var i = 1; i < _smoothedData.length; i++) {
        if (stDeviation(
                _smoothedData[i]["acc.x"],
                _smoothedData[i - 1]["acc.x"],
                mean(
                    _smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"])) >
            0.3) {
          if (startAbnormal != true && i != _smoothedData.length - 1) {
            startAbnormal = true;
            abnormalBeginIndex = i - 1;
            print("Start time: ${_smoothedData[i]['time']}");
          }
          if (i == _smoothedData.length - 1 && startAbnormal == true) {
            startAbnormal = false;
            if ((_smoothedData[i]["time"] -
                    _smoothedData[abnormalBeginIndex]["time"]) >=
                2.5) {
              print("End time: ${_smoothedData[i]['time']}");
              abnormal += 1;
              _abnormalClassifications.add(classifyAbnormal(
                  _smoothedData, _dataModels, abnormalBeginIndex, i));
            }
          }
        } else if (startAbnormal == true && i == _smoothedData.length - 1) {
          startAbnormal = false;

          if ((_smoothedData[i]["time"] -
                  _smoothedData[abnormalBeginIndex]["time"]) >=
              2.5) {
            print("End time: ${_smoothedData[i]['time']}");
            abnormal += 1;
            _abnormalClassifications.add(classifyAbnormal(
                _smoothedData, _dataModels, abnormalBeginIndex, i));
          }
        } else if (startAbnormal == true) {
          if (stDeviation(
                  _smoothedData[i]["acc.x"],
                  _smoothedData[i + 1]["acc.x"],
                  mean(_smoothedData[i]["acc.x"],
                      _smoothedData[i + 1]["acc.x"])) >
              0.23) {
            print("Continue");
          } else if (i != _smoothedData.length - 2 &&
              stDeviation(
                      _smoothedData[i + 1]["acc.x"],
                      _smoothedData[i + 2]["acc.x"],
                      mean(_smoothedData[i + 1]["acc.x"],
                          _smoothedData[i + 2]["acc.x"])) >
                  0.23) {
            print("Continue");
          } else {
            startAbnormal = false;

            if ((_smoothedData[i]["time"] -
                    _smoothedData[abnormalBeginIndex]["time"]) >=
                2.5) {
              print("Start time: ${_smoothedData[abnormalBeginIndex]['time']}");
              print("End time: ${_smoothedData[i]['time']}");
              abnormal += 1;
              _abnormalClassifications.add(classifyAbnormal(
                  _smoothedData, _dataModels, abnormalBeginIndex, i));
            }
          }
        }
        if (_smoothedData[i]['time'] % 60 == 0 ||
            i == _smoothedData.length - 1) {
          print("In 60");
          print("Abn in 60: $abnormal");
          allTripAbnormal.add(abnormal);
          abnormal = 0;
        }
      }

      // print(_abnormalClassifications);

      if (_abnormalClassifications.length > 0) {
        for (var ab in _abnormalClassifications) {
          ab == "Weaving"
              ? _weaving++
              : ab == "Swerving"
                  ? _swerving++
                  : ab == "Fast U-turn" ? _fastUTurn++ : _suddenBraking++;
        }
        // print("In analys");
        // print("Weaving: $_weaving");
        // print("Swerving: $_swerving");
        // print("Fast: $_fastUTurn");
        // print("Sudden: $_suddenBraking");
      }
    });
  }

  String classifyAbnormal(
      _data, _dataModels, int abnormalBeginIndex, int abnormalEndIndex) {
    List<Map<String, dynamic>> dataOfAbnormal = [];
    var featuresOfAbnormal = {};
    String classification = "";

    for (var i = abnormalBeginIndex; i <= abnormalEndIndex; i++) {
      dataOfAbnormal.add(_data[i]);
    }
    featuresOfAbnormal = calculateUnknown(dataOfAbnormal);
    // print(featuresOfAbnormal);

    classification = KNN(featuresOfAbnormal, _dataModels);
    return classification;
  }

  Future<void> showProfile(BuildContext context, args) {
    // print("Weaving: $_weaving");
    // print("Swerving: $_swerving");
    // print("Fast: $_fastUTurn");
    // print("Sudden: $_suddenBraking");
    // print("Abnormal data: $allTripAbnormal");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);
        var _darkTheme = (themeNotifier.getTheme() == darkTheme);
        var _height = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: Text(
            'Behavior Profiling',
            style: TextStyle(
                color: _darkTheme ? Colors.white : Color(0xFF2a4848),
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w300,
                fontSize: _height * 0.022),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[getProfile(_height, _darkTheme)],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: _darkTheme ? Colors.white : Color(0xFF2a4848),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w300,
                    fontSize: _height * 0.022),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, TripAnalysPage.routeName,
                    arguments: PassToTripAnalysArgs(args.auth, args.userId,
                        _weaving, _swerving, _fastUTurn, _suddenBraking));
              },
            ),
          ],
        );
      },
    );
  }

  Widget getProfile(_height, _darkTheme) {
    double dsi, dsiAverage = 0;
    // print("GetProfile: $allTripAbnormal");
    for (var i in allTripAbnormal) {
      dsi = 1 - 0.25 * i;
      // print("dsi: $dsi");
      dsiAverage += dsi;
    }
    dsiAverage /= allTripAbnormal.length;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
                style: TextStyle(
                    color: _darkTheme ? Colors.white : Color(0xFF336666),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w300,
                    fontSize: _height * 0.022),
                children: <TextSpan>[
                  TextSpan(
                      text: allTripAbnormal.length > 0
                          ? "You are "
                          : "No data to analys behavior"),
                  TextSpan(
                    text: allTripAbnormal.length <= 0
                        ? null
                        : dsiAverage >= 0.9
                            ? " a VERY SAFE "
                            : dsiAverage >= 0.7
                                ? "a SAFE "
                                : dsiAverage >= 0.5
                                    ? "an AGGRESSIVE "
                                    : "a VERY AGGRESSIVE ",
                    style: TextStyle(
                        color: dsiAverage >= 0.9
                            ? Colors.green[700]
                            : dsiAverage >= 0.7
                                ? Colors.green[300]
                                : dsiAverage >= 0.5
                                    ? Colors.orange
                                    : Colors.red,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w900,
                        fontSize: _height * 0.022),
                  ),
                  TextSpan(
                      text: allTripAbnormal.length <= 0
                          ? null
                          : dsiAverage >= 0.9
                              ? "driver. Keep it that way!"
                              : dsiAverage >= 0.7
                                  ? "driver, but not ideal. Try not to do dangerous maneuvers."
                                  : dsiAverage >= 0.5
                                      ? "driver. Calm down and drive car carefully!"
                                      : "driver. Calm down! Someone is waiting for you at home!")
                ]),
          ),
        ]);
  }

  // SMA - Simple Moving Average
  List<Map<String, dynamic>> smoothingSMAUnknown(data) {
    List<Map<String, dynamic>> smoothed = <Map<String, dynamic>>[];
    double smoothedAccX, smoothedAccY, smoothedOriX, smoothedOriY;
    print("Smooting");
    for (var i = 1; i < data.length; i++) {
      smoothedAccX = mean(data[i - 1]["acc.x"], data[i]["acc.x"]);
      smoothedAccY = mean(data[i - 1]["acc.y"], data[i]["acc.y"]);
      smoothedOriX = mean(data[i - 1]["ori.x"], data[i]["ori.x"]);
      smoothedOriY = mean(data[i - 1]["ori.y"], data[i]["ori.y"]);
      smoothed.add({
        "acc.x": smoothedAccX,
        "acc.y": smoothedAccY,
        "ori.x": smoothedOriX,
        "ori.y": smoothedOriY,
        "time": data[i]["time"]
      });
    }
    return smoothed;
  }

  dynamic _makeTemplate() async{
    var list;
    
    list = json.decode(await rootBundle.loadString('models/tripSafe.json'));
    return list;
  }
}

Future<void> writeDataToJSON(data, args, startTime, endTime) async {
  // print("DATA");
  // print(data);
  Firestore.instance.collection("trip").document().setData({
    "uid": args.userId,
    "data": data,
    "startTime": startTime,
    "endTime": endTime
  });
}
