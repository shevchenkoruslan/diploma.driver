import 'dart:convert';
import 'dart:io';
import 'dart:math';
// import 'behaviorModels.dart';

List<Map<String, dynamic>> _weaving = [
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 0.0, "ori.y": 0.0, "time": 0},
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 0.0, "ori.y": 0.0, "time": 0.5},
  {"acc.x": -0.5, "acc.y": 0.5, "ori.x": -2.5, "ori.y": 0.0, "time": 1},
  {"acc.x": -2.8, "acc.y": 1.5, "ori.x": -5.5, "ori.y": -1.0, "time": 1.5},
  {"acc.x": -2.4, "acc.y": 0.9, "ori.x": -2.5, "ori.y": -0.6, "time": 2},
  {"acc.x": 1.3, "acc.y": 0.0, "ori.x": 1.0, "ori.y": 0.0, "time": 2.5},
  {"acc.x": 3.0, "acc.y": 0.1, "ori.x": -2.5, "ori.y": 0.0, "time": 3},
  {"acc.x": 1.5, "acc.y": 0.6, "ori.x": -5.2, "ori.y": -0.3, "time": 3.5},
  {"acc.x": 0.3, "acc.y": 0.7, "ori.x": -5.5, "ori.y": -0.5, "time": 4},
  {"acc.x": 0.0, "acc.y": 0.6, "ori.x": -6.0, "ori.y": -0.5, "time": 4.5},
  {"acc.x": -1.0, "acc.y": 1.2, "ori.x": -6.5, "ori.y": -0.5, "time": 5},
  {"acc.x": -2.4, "acc.y": 1.2, "ori.x": -2.0, "ori.y": -0.3, "time": 5.5},
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 3.5, "ori.y": 0.0, "time": 6},
  {"acc.x": 5.2, "acc.y": -0.5, "ori.x": 0.5, "ori.y": 0.1, "time": 6.5},
  {"acc.x": 4.2, "acc.y": 0.5, "ori.x": -4.5, "ori.y": -0.1, "time": 7},
  {"acc.x": -1.0, "acc.y": 1.0, "ori.x": -5.5, "ori.y": -0.3, "time": 7.5},
  {"acc.x": -5.1, "acc.y": 0.6, "ori.x": -3.5, "ori.y": -0.1, "time": 8},
  {"acc.x": -2.6, "acc.y": -0.1, "ori.x": 0.0, "ori.y": 0.0, "time": 8.5},
  {"acc.x": 3.3, "acc.y": 0.5, "ori.x": 0.7, "ori.y": -0.3, "time": 9},
  {"acc.x": 3.0, "acc.y": 0.9, "ori.x": -6.0, "ori.y": -0.5, "time": 9.5},
  {"acc.x": -2.0, "acc.y": 0.5, "ori.x": -5.5, "ori.y": -0.5, "time": 10},
  {"acc.x": -4.2, "acc.y": 0.2, "ori.x": -0.5, "ori.y": -0.5, "time": 10.5},
  {"acc.x": 0.1, "acc.y": 0.3, "ori.x": 0.5, "ori.y": -0.5, "time": 11},
  {"acc.x": 2.1, "acc.y": 0.6, "ori.x": -2.5, "ori.y": -0.3, "time": 11.5},
  {"acc.x": -0.1, "acc.y": 0.3, "ori.x": -5.0, "ori.y": -0.3, "time": 12},
  {"acc.x": -1.4, "acc.y": 0.0, "ori.x": -4.0, "ori.y": 0.0, "time": 12.5},
  {"acc.x": -1.0, "acc.y": -0.2, "ori.x": -2.0, "ori.y": 0.0, "time": 13},
  {"acc.x": -0.6, "acc.y": 0.0, "ori.x": 0.3, "ori.y": -0.5, "time": 13.5},
  {"acc.x": -0.5, "acc.y": 0.6, "ori.x": -0.7, "ori.y": -0.5, "time": 14},
  {"acc.x": -0.4, "acc.y": 0.5, "ori.x": -2.0, "ori.y": -0.4, "time": 14.5},
  {"acc.x": -0.3, "acc.y": 0.0, "ori.x": -2.3, "ori.y": -0.5, "time": 15},
];

List<Map<String, dynamic>> _swerving = [
  {"acc.x": -0.3, "acc.y": 1.2, "ori.x": -10.0, "ori.y": -0.3, "time": 0},
  {"acc.x": 2.5, "acc.y": 1.0, "ori.x": -10.2, "ori.y": -0.2, "time": 0.5},
  {"acc.x": 1.9, "acc.y": 1.9, "ori.x": -7.5, "ori.y": -0.3, "time": 1},
  {"acc.x": -9.7, "acc.y": -0.1, "ori.x": 2.3, "ori.y": 0.1, "time": 1.5},
  {"acc.x": 1.4, "acc.y": 1.4, "ori.x": -11.5, "ori.y": -0.1, "time": 2},
  {"acc.x": -1.9, "acc.y": 0.9, "ori.x": -9.0, "ori.y": -0.1, "time": 2.5},
  {"acc.x": -1.0, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 3},
];

List<Map<String, dynamic>> _fastUTurn = [
  {"acc.x": -0.9, "acc.y": -1.2, "ori.x": -1.2, "ori.y": 0.7, "time": 0},
  {"acc.x": -1.2, "acc.y": -2.1, "ori.x": 0.0, "ori.y": 0.5, "time": 0.5},
  {"acc.x": -0.9, "acc.y": -2.4, "ori.x": 0.2, "ori.y": 0.4, "time": 1},
  {"acc.x": 0.0, "acc.y": -2.1, "ori.x": -2.0, "ori.y": 0.5, "time": 1.5},
  {"acc.x": 0.2, "acc.y": -1.5, "ori.x": -4.4, "ori.y": 0.3, "time": 2},
  {"acc.x": -0.4, "acc.y": -0.3, "ori.x": -4.0, "ori.y": 0.0, "time": 2.5},
  {"acc.x": -3.9, "acc.y": -0.8, "ori.x": -3.9, "ori.y": 0.3, "time": 3},
  {"acc.x": -6.6, "acc.y": -2.7, "ori.x": -3.4, "ori.y": 0.7, "time": 3.5},
  {"acc.x": -7.8, "acc.y": -2.6, "ori.x": -2.8, "ori.y": 0.8, "time": 4},
  {"acc.x": -7.0, "acc.y": -1.1, "ori.x": -2.7, "ori.y": 0.4, "time": 4.5},
  {"acc.x": -7.5, "acc.y": -0.5, "ori.x": -0.8, "ori.y": 0.0, "time": 5},
  {"acc.x": -8.4, "acc.y": -0.3, "ori.x": 2.4, "ori.y": 0.3, "time": 5.5},
  {"acc.x": -6.9, "acc.y": 0.3, "ori.x": 2.0, "ori.y": -0.3, "time": 6},
  {"acc.x": -5.1, "acc.y": 1.7, "ori.x": 1.9, "ori.y": -0.4, "time": 6.5},
  {"acc.x": -1.7, "acc.y": 2.1, "ori.x": 3.2, "ori.y": -0.6, "time": 7},
  {"acc.x": 0.1, "acc.y": 2.4, "ori.x": 4.0, "ori.y": -0.8, "time": 7.5},
  {"acc.x": 0.0, "acc.y": 2.4, "ori.x": 2.0, "ori.y": -0.7, "time": 8},
  {"acc.x": -0.1, "acc.y": 2.3, "ori.x": 1.0, "ori.y": -0.7, "time": 8.5},
  {"acc.x": -0.2, "acc.y": 1.5, "ori.x": 0.7, "ori.y": -0.4, "time": 9},
  {"acc.x": -0.3, "acc.y": 1.2, "ori.x": 2.0, "ori.y": -0.3, "time": 9.5},
  {"acc.x": -0.4, "acc.y": 1.7, "ori.x": 2.3, "ori.y": -0.6, "time": 10},
];

List<Map<String, dynamic>> _suddenBraking = [
  {"acc.x": -2.0, "acc.y": 2.1, "ori.x": -6.0, "ori.y": -1.5, "time": 0},
  {"acc.x": -1.6, "acc.y": -0.8, "ori.x": -8.9, "ori.y": 0.0, "time": 0.5},
  {"acc.x": -0.5, "acc.y": -5.0, "ori.x": -13.0, "ori.y": 2.7, "time": 1},
  {"acc.x": -0.2, "acc.y": -4.0, "ori.x": -12.2, "ori.y": 1.4, "time": 1.5},
  {"acc.x": -0.1, "acc.y": -4.2, "ori.x": -12.4, "ori.y": 1.7, "time": 2},
  {"acc.x": 0.0, "acc.y": -4.0, "ori.x": -12.1, "ori.y": 1.6, "time": 2.5},
  {"acc.x": 0.1, "acc.y": -4.9, "ori.x": -13.5, "ori.y": 1.7, "time": 3},
  {"acc.x": 0.0, "acc.y": -0.2, "ori.x": -10.5, "ori.y": 0.0, "time": 3.5},
  {"acc.x": -0.1, "acc.y": 1.0, "ori.x": -9.8, "ori.y": -0.3, "time": 4},
];

List<Map<String, dynamic>> _unknown = [
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 0.0, "ori.y": 0.0, "time": 0},
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 0.0, "ori.y": 0.0, "time": 0.5},
  {"acc.x": -0.5, "acc.y": 0.5, "ori.x": -2.5, "ori.y": 0.0, "time": 1},
  {"acc.x": -2.8, "acc.y": 1.5, "ori.x": -5.5, "ori.y": -1.0, "time": 1.5},
  {"acc.x": -2.4, "acc.y": 0.9, "ori.x": -2.5, "ori.y": -0.6, "time": 2},
  {"acc.x": 1.3, "acc.y": 0.0, "ori.x": 1.0, "ori.y": 0.0, "time": 2.5},
  {"acc.x": 3.0, "acc.y": 0.1, "ori.x": -2.5, "ori.y": 0.0, "time": 3},
  {"acc.x": 1.5, "acc.y": 0.6, "ori.x": -5.2, "ori.y": -0.3, "time": 3.5},
  {"acc.x": 0.3, "acc.y": 0.7, "ori.x": -5.5, "ori.y": -0.5, "time": 4},
  {"acc.x": 0.0, "acc.y": 0.6, "ori.x": -6.0, "ori.y": -0.5, "time": 4.5},
  {"acc.x": -1.0, "acc.y": 1.2, "ori.x": -6.5, "ori.y": -0.5, "time": 5},
  {"acc.x": -2.4, "acc.y": 1.2, "ori.x": -2.0, "ori.y": -0.3, "time": 5.5},
  {"acc.x": 0.0, "acc.y": 0.0, "ori.x": 3.5, "ori.y": 0.0, "time": 6},
  {"acc.x": 5.2, "acc.y": -0.5, "ori.x": 0.5, "ori.y": 0.1, "time": 6.5},
  {"acc.x": 4.2, "acc.y": 0.5, "ori.x": -4.5, "ori.y": -0.1, "time": 7},
  {"acc.x": -1.0, "acc.y": 1.0, "ori.x": -5.5, "ori.y": -0.3, "time": 7.5},
  {"acc.x": -5.1, "acc.y": 0.6, "ori.x": -3.5, "ori.y": -0.1, "time": 8},
];

double mean(List<double> list) {
  // print(list);
  var sum = 0.0;
  // if (beginIndex != 0 || endIndex != list.length) {
  // int length = endIndex - beginIndex;
  // print("Length: $length");
  // print("beginIndex: $beginIndex");
  // print("endIndex: $endIndex");
  // }
  // if (beginIndex == endIndex) {
  //   return list[beginIndex];
  // } else {
  //   for (var i = beginIndex; i < endIndex; i++) {
  //     sum += list[i];
  //   }
  //   sum /= endIndex - beginIndex;
  //   return sum;
  // }
  for (var i in list) {
    sum += i;
  }
  return (sum / list.length);
}

double meanFirstHalf(List<double> list, int endIndex) {
  // print("EndIndex: $endIndex");
  var sum = 0.0;
  for (var i = 0; i < endIndex; i++){
    sum += list[i];
  }
  return (sum/endIndex);
}

double meanSecondHalf(List<double> list, int beginIndex) {
  // print("BeginIndex: $beginIndex");
  var sum = 0.0;
  for (var i = beginIndex; i < list.length; i++){
    sum += list[i];
  }
  if (beginIndex == list.length){
    return sum;
  }
  if (list.length == 1) {
    return 0;
  }
  // print("Length: " + (list.length - beginIndex).toString());
  return (sum/(list.length - beginIndex));
}

double standartDeviation(List<double> list, meanAccX) {
  var deviation = 0.0;
  for (var i in list) {
    deviation += pow((i - meanAccX), 2);
  }
  deviation = sqrt(deviation / (list.length - 1));
  return deviation;
}

double range(List<double> list) {
  return list.reduce(max) - list.reduce(min);
}

calculate(List<Map<String, dynamic>> list, classification) {
  List<double> listOfValues = [];
  var _meanAccX,
      _meanAccY,
      _meanOriX,
      _meanOriY,
      _standartDeviationAccX,
      _standartDeviationAccY,
      _standartDeviationOriX,
      _standartDeviationOriY,
      _rangeAccX,
      _rangeAccY,
      _meanFirstHalfAccX,
      _meanSecondHalfAccX,
      _maxOriX,
      _maxOriY,
      _minAccY,
      // _rangeOriX,
      // _rangeOriY,
      _duration;

// Acc.X
  for (var i in list) {
    listOfValues.add(i["acc.x"]);
  }
  _meanAccX = mean(listOfValues);
  // print("Mean AccX: $_meanAccX");
  _standartDeviationAccX = standartDeviation(listOfValues, _meanAccX);
  // print("Standart Deviation AccX: $_standartDeviationAccX");
  _rangeAccX = range(listOfValues);
  // print("Range AccX: $_rangeAccX");
  _meanFirstHalfAccX = meanFirstHalf(listOfValues, (listOfValues.length / 2).floor());
  _meanSecondHalfAccX = meanSecondHalf(
      listOfValues, (listOfValues.length / 2).floor());

// Acc.Y
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["acc.y"]);
  }
  _meanAccY = mean(listOfValues);
  // print("Mean AccY: $_meanAccY");
  _standartDeviationAccY = standartDeviation(listOfValues, _meanAccY);
  // print("Standart Deviation AccY: $_standartDeviationAccY");
  _rangeAccY = range(listOfValues);
  // print("Range AccY: $_rangeAccY");
  _minAccY = listOfValues.reduce(min);

// Ori.X
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["ori.x"]);
  }
  _meanOriX = mean(listOfValues);
  // print("Mean OriX: $_meanOriX");
  _standartDeviationOriX = standartDeviation(listOfValues, _meanOriX);
  // print("Standart Deviation OriX: $_standartDeviationOriX");
  // _rangeOriX = range(listOfValues);
  // print("Range OriX: $_rangeOriX");
  _maxOriX = listOfValues.reduce(max);

// Ori.Y
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["ori.y"]);
  }
  _meanOriY = mean(listOfValues);
  // print("Mean OriY: $_meanOriY");
  _standartDeviationOriY = standartDeviation(listOfValues, _meanOriY);
  // print("Standart Deviation OriY: $_standartDeviationOriY");
  // _rangeOriY = range(listOfValues);
  // print("Range AccY: $_rangeOriY");
  _maxOriY = listOfValues.reduce(max);
  _duration = list.last["time"] - list.first["time"];
  _duration = list.last["time"];
  // print(_duration);

  var _model = {
    "Range_Acc_X": _rangeAccX,
    "Range_Acc_Y": _rangeAccY,

    "Mean_Acc_X": _meanAccX,
    "Mean_Acc_Y": _meanAccY,
    "Mean_Ori_X": _meanOriX,
    "Mean_Ori_Y": _meanOriY,

    "St_Deviation_Acc_X": _standartDeviationAccX,
    "St_Deviation_Acc_Y": _standartDeviationAccY,
    "St_Deviation_Ori_X": _standartDeviationOriX,
    "St_Deviation_Ori_Y": _standartDeviationOriY,

    "Mean_first_half_Acc_X": _meanFirstHalfAccX,
    "Mean_second_half_Acc_X": _meanSecondHalfAccX,
    "Max_Ori_X": _maxOriX,
    "Max_Ori_Y": _maxOriY,
    "Min_Acc_Y": _minAccY,

    // "Range_Ori_X": _rangeOriX,
    // "Range_Ori_Y": _rangeOriY,
    "Duration": _duration,
    "Classification": classification
  };
  return _model;
}

calculateUnknown(List<Map<String, dynamic>> list) {
//   List<double> listOfValues = [];
//   var data = {};
//   var _meanAccX,
//       _meanAccY,
//       _meanOriX,
//       _meanOriY,
//       _standartDeviationAccX,
//       _standartDeviationAccY,
//       _standartDeviationOriX,
//       _standartDeviationOriY,
//       _rangeAccX,
//       _rangeAccY,
//       _rangeOriX,
//       _rangeOriY,
//       _duration;

// // Acc.X
//   for (var i in list) {
//     listOfValues.add(i["acc.x"]);
//   }
//   _meanAccX = mean(listOfValues);
//   // print("Mean AccX: $_meanAccX");
//   _standartDeviationAccX = standartDeviation(listOfValues, _meanAccX);
//   // print("Standart Deviation AccX: $_standartDeviationAccX");
//   _rangeAccX = range(listOfValues);
//   // print("Range AccX: $_rangeAccX");

// // Acc.Y
//   listOfValues.clear();
//   for (var i in list) {
//     listOfValues.add(i["acc.y"]);
//   }
//   _meanAccY = mean(listOfValues);
//   // print("Mean AccY: $_meanAccY");
//   _standartDeviationAccY = standartDeviation(listOfValues, _meanAccY);
//   // print("Standart Deviation AccY: $_standartDeviationAccY");
//   _rangeAccY = range(listOfValues);
//   // print("Range AccY: $_rangeAccY");

// // Ori.X
//   listOfValues.clear();
//   for (var i in list) {
//     listOfValues.add(i["ori.x"]);
//   }
//   _meanOriX = mean(listOfValues);
//   // print("Mean OriX: $_meanOriX");
//   _standartDeviationOriX = standartDeviation(listOfValues, _meanOriX);
//   // print("Standart Deviation OriX: $_standartDeviationOriX");
//   _rangeOriX = range(listOfValues);
//   // print("Range OriX: $_rangeOriX");

// // Ori.Y
//   listOfValues.clear();
//   for (var i in list) {
//     listOfValues.add(i["ori.y"]);
//   }
//   _meanOriY = mean(listOfValues);
//   // print("Mean OriY: $_meanOriY");
//   _standartDeviationOriY = standartDeviation(listOfValues, _meanOriY);
//   // print("Standart Deviation OriY: $_standartDeviationOriY");
//   _rangeOriY = range(listOfValues);
//   // print("Range AccY: $_rangeOriY");
//   _duration = list.last["time"] - list.first["time"];
//   // print(_duration);

//   data = {
//     "Mean_Acc_X": _meanAccX,
//     "Mean_Acc_Y": _meanAccY,
//     "Mean_Ori_X": _meanOriX,
//     "Mean_Ori_Y": _meanOriY,
//     "St_Deviation_Acc_X": _standartDeviationAccX,
//     "St_Deviation_Acc_Y": _standartDeviationAccY,
//     "St_Deviation_Ori_X": _standartDeviationOriX,
//     "St_Deviation_Ori_Y": _standartDeviationOriY,
//     "Range_Acc_X": _rangeAccX,
//     "Range_Acc_Y": _rangeAccY,
//     "Range_Ori_X": _rangeOriX,
//     "Range_Ori_Y": _rangeOriY,
//     "Duration": _duration,
//   };
//   // print("Data");
//   // print(data);
//   return data;
//   // print(listToSave);
//   // return listToSave;
  List<double> listOfValues = [];
  var _meanAccX,
      _meanAccY,
      _meanOriX,
      _meanOriY,
      _standartDeviationAccX,
      _standartDeviationAccY,
      _standartDeviationOriX,
      _standartDeviationOriY,
      _rangeAccX,
      _rangeAccY,
      _meanFirstHalfAccX,
      _meanSecondHalfAccX,
      _maxOriX,
      _maxOriY,
      _minAccY,
      // _rangeOriX,
      // _rangeOriY,
      _duration;

// Acc.X
  for (var i in list) {
    listOfValues.add(i["acc.x"]);
  }
  _meanAccX = mean(listOfValues);
  // print("Mean AccX: $_meanAccX");
  _standartDeviationAccX = standartDeviation(listOfValues, _meanAccX);
  // print("Standart Deviation AccX: $_standartDeviationAccX");
  _rangeAccX = range(listOfValues);
  // print("Range AccX: $_rangeAccX");
  _meanFirstHalfAccX = meanFirstHalf(listOfValues, (listOfValues.length / 2).floor());
  _meanSecondHalfAccX = meanSecondHalf(
      listOfValues, (listOfValues.length / 2).floor() + 1);

// Acc.Y
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["acc.y"]);
  }
  _meanAccY = mean(listOfValues);
  // print("Mean AccY: $_meanAccY");
  _standartDeviationAccY = standartDeviation(listOfValues, _meanAccY);
  // print("Standart Deviation AccY: $_standartDeviationAccY");
  _rangeAccY = range(listOfValues);
  // print("Range AccY: $_rangeAccY");
  _minAccY = listOfValues.reduce(min);

// Ori.X
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["ori.x"]);
  }
  _meanOriX = mean(listOfValues);
  // print("Mean OriX: $_meanOriX");
  _standartDeviationOriX = standartDeviation(listOfValues, _meanOriX);
  // print("Standart Deviation OriX: $_standartDeviationOriX");
  // _rangeOriX = range(listOfValues);
  // print("Range OriX: $_rangeOriX");
  _maxOriX = listOfValues.reduce(max);

// Ori.Y
  listOfValues.clear();
  for (var i in list) {
    listOfValues.add(i["ori.y"]);
  }
  _meanOriY = mean(listOfValues);
  // print("Mean OriY: $_meanOriY");
  _standartDeviationOriY = standartDeviation(listOfValues, _meanOriY);
  // print("Standart Deviation OriY: $_standartDeviationOriY");
  // _rangeOriY = range(listOfValues);
  // print("Range AccY: $_rangeOriY");
  _maxOriY = listOfValues.reduce(max);
  _duration = list.last["time"] - list.first["time"];
  // print(_duration);

  var _data = {
    "Range_Acc_X": _rangeAccX,
    "Range_Acc_Y": _rangeAccY,

    "Mean_Acc_X": _meanAccX,
    "Mean_Acc_Y": _meanAccY,
    "Mean_Ori_X": _meanOriX,
    "Mean_Ori_Y": _meanOriY,

    "St_Deviation_Acc_X": _standartDeviationAccX,
    "St_Deviation_Acc_Y": _standartDeviationAccY,
    "St_Deviation_Ori_X": _standartDeviationOriX,
    "St_Deviation_Ori_Y": _standartDeviationOriY,

    "Mean_first_half_Acc_X": _meanFirstHalfAccX,
    "Mean_second_half_Acc_X": _meanSecondHalfAccX,
    "Max_Ori_X": _maxOriX,
    "Max_Ori_Y": _maxOriY,
    "Min_Acc_Y": _minAccY,

    // "Range_Ori_X": _rangeOriX,
    // "Range_Ori_Y": _rangeOriY,
    "Duration": _duration,
  };
  // print(_data);
  return _data;
}

Future<void> main() async {
  List<dynamic> _dataModels = [];
  var _dataOfUnknown = {};
  _dataModels =
      json.decode(await File('models/behaviorModels.json').readAsString());
  

  // var _model;
  // calculateModelAndWriteToFile(_fastUTurn, "Fast U-turn");
  // _model = calculate(_fastUTurn, "Fast U-turn");
  // writeToFile(_model);

  // // print(_dataModels);

  _dataOfUnknown = calculateUnknown(_unknown);
  // print(_dataOfUnknown);
  KNN(_dataOfUnknown, _dataModels);
}

void calculateModelAndWriteToFile(
    List<Map<String, dynamic>> sensorsData, String classification) {
  var _model;
  _model = calculate(sensorsData, classification);
  writeToFile(_model);
}

String KNN(_dataOfUnknown, _dataModels) {
  int k = 4;
  List<double> dist = [];
  bool equalClassifications = false;
  String classification;

  // print("Length: " + _dataModels.length.toString());
  // print("Data of unknow");
  // print(_dataOfUnknown);
  for (var i in _dataModels) {
    dist.add(calculateDistance(_dataOfUnknown, i));
  }
  // dist.add(20);
  // print(dist);

  var indexes = [];
  var distances = [];
  for (var j = 0; j < k; j++) {
    var min = 1000.0;
    for (var i in dist) {
      if (i < min && i >= 0) {
        min = i;
      }
    }
    indexes.add(dist.indexOf(min));
    distances.add(min);
    dist[dist.indexOf(min)] = -1;
  }
  print(indexes);
  print(distances);

  for (var i = 1; i < _dataModels.length; i++) {
    if (_dataModels[i]['Classification'] ==
        _dataModels[i - 1]['Classification']) {
      equalClassifications = true;
    } else {
      equalClassifications = false;
      break;
    }
  }

  if (equalClassifications) {
    classification = _dataModels[0]['Classification'];
  } else {
    classification = vote(indexes, distances, _dataModels);
  }

  // print(classification);
  return classification;
}

String vote(List indexes, List distances, _dataModels) {
  List<Map<String, dynamic>> votes = [];
  String classification;
  // List<Map<String, dynamic>> vote = [];
  // double newVote;
  for (var i in distances) {
    votes.add({
      "vote": (1 / pow(i, 2)),
      "classification": _dataModels[indexes[distances.indexOf(i)]]
          ['Classification']
    });
    // votes.add(1/pow(i,2));
    // print(indexes[distances.indexOf(i)]);
  }
  // print(votes);
  for (var i = 0; i < votes.length - 1; i++) {
    for (var j = 1; j < votes.length; j++) {
      if (i != j) {
        if (votes[i]['classification'] == votes[j]['classification']) {
          votes[i]['vote'] += votes[j]['vote'];
          votes.removeAt(j);
          // print(votes.length);
        }
      }
    }
  }
  // print(votes);
  var biggestVote = votes[0]['vote'];
  classification = votes[0]['classification'];
  for (var i = 1; i < votes.length; i++) {
    if (votes[i]['vote'] > biggestVote) {
      biggestVote = votes[i]['vote'];
      classification = votes[i]['classification'];
    }
  }
  return classification;

  // print(vote);
}

double calculateDistance(dataOfUnknown, model) {
  var dist = 0.0;
  // print("data of unknown in calculate distance");
  // print(dataOfUnknown);
  for (var key in model.keys) {
    if (key != "Classification") {
      // print(dataOfUnknown[key]);
      dist += pow((dataOfUnknown[key] - model[key]), 2);
    }
  }
  dist = sqrt(dist);
  // print("Dist: $dist");
  return dist;
}

void writeToFile(_model) {
  print("Writing to file!");
  // Map<String, dynamic> content = {key: value};
  var jsonFile = File("models/behaviorModels.json");

  List<dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
  // print("JS");
  // print(jsonFileContent);
  jsonFileContent.add(_model);
  jsonFile.writeAsStringSync(json.encode(jsonFileContent));
}
