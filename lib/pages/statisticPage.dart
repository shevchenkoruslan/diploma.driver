import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constants/constants.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class StatisticPage extends StatefulWidget {
  StatisticPage({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage>
    with TickerProviderStateMixin {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<int> _isClicked;

  @override
  void initState() {
    super.initState();
    _isClicked = List();
  }

  void _checkIsClicked(int index) {
    if (_isClicked.contains(index)) {
      _isClicked.remove(index);
      setState(() {});
    } else {
      _isClicked.add(index);
      setState(() {});
    }
  }

  Color getColor(int value) {
    if (value <= 40)
      return Color(0xFFFF0000);
    else if (value <= 60)
      return Color(0xFFFF6600);
    else if (value <= 80)
      return Color(0xFF33CC33);
    else
      return Colors.blue;
  }

  _sortList(list) {
    list.sort((a, b) => Comparable.compare(b['startTime'], a['startTime']));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("images/road.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(top: _height * 0.096),
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("statistics")
                      .getDocuments()
                      .asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var list = snapshot.data.documents
                          .map((docs) => docs.data)
                          .where((d) => d['uid'] == widget.userId)
                          .toList();
                      _sortList(list);
                      return list.length != 0
                          ? ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        _checkIsClicked(index);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                            16.0,
                                            _height * 0.012,
                                            16.0,
                                            _height * 0.019),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 10.0,
                                          color: _darkTheme
                                              ? Color(0xFF1d3a38)
                                              : Colors.white,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 20.0,
                                                top: _height * 0.006,
                                                right: 0.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      height: _height * 0.084,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            DateFormat(
                                                                    "dd.MM, HH:mm")
                                                                .format(list[
                                                                            index]
                                                                        [
                                                                        'startTime']
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                color: _darkTheme
                                                                    ? Colors
                                                                        .white
                                                                    : Color(
                                                                        0xFF336666),
                                                                fontFamily:
                                                                    "Montserrat",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    _height *
                                                                        0.017),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    "dd.MM, HH:mm")
                                                                .format(list[
                                                                            index]
                                                                        [
                                                                        'endTime']
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                color: _darkTheme
                                                                    ? Colors
                                                                        .white
                                                                    : Color(
                                                                        0xFF336666),
                                                                fontFamily:
                                                                    "Montserrat",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    _height *
                                                                        0.017),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          list[index]['average']
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: getColor(
                                                                  list[index][
                                                                      'average']),
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  _height *
                                                                      0.029),
                                                        ),
                                                        SizedBox(width: 5.0),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            SizedBox(
                                                                height: 5.0),
                                                            Text(
                                                              "points",
                                                              style: TextStyle(
                                                                  color: _darkTheme
                                                                      ? Colors
                                                                          .white
                                                                      : Color(
                                                                          0xFF2a4848),
                                                                  fontFamily:
                                                                      "Montserrat",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      _height *
                                                                          0.0144),
                                                            ),
                                                          ],
                                                        ),
                                                        IconButton(
                                                            icon: (_isClicked ==
                                                                        null ||
                                                                    !_isClicked
                                                                        .contains(
                                                                            index))
                                                                ? Icon(
                                                                    Icons
                                                                        .arrow_back_ios,
                                                                    color: _darkTheme
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    size: 14.0,
                                                                  )
                                                                : Transform
                                                                    .rotate(
                                                                    angle: 270 *
                                                                        pi /
                                                                        180,
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_back_ios,
                                                                      color: _darkTheme
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      size:
                                                                          14.0,
                                                                    ),
                                                                  ),
                                                            onPressed: () {
                                                              print("Pressed");
                                                              _checkIsClicked(
                                                                  index);
                                                              setState(() {});
                                                            }),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                AnimatedSize(
                                                  curve: Curves.easeInToLinear,
                                                  vsync: this,
                                                  duration: new Duration(
                                                      milliseconds: 500),
                                                  child: (_isClicked == null ||
                                                          !_isClicked
                                                              .contains(index))
                                                      ? Container()
                                                      : cardMore(
                                                          index,
                                                          list,
                                                          _darkTheme,
                                                          _height,
                                                          _width),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 40,
                                      child: Container(
                                        width: _width * 0.255,
                                        height: _height * 0.0362,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: _darkTheme
                                              ? Color(0xFFe6e6e6)
                                              : Color(0xFF2a4848),
                                        ),
                                        child: Text(
                                          "TRIP",
                                          style: TextStyle(
                                              fontSize: _height * 0.017,
                                              color: _darkTheme
                                                  ? Color(0xFF2a4848)
                                                  : Colors.white,
                                              fontFamily: "Palatino",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: Container(
                                height: MediaQuery.of(context).size.height / 10,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                // padding: EdgeInsets.fromLTRB(
                                //     _height * 0.024, 0, 0, 0),
                                decoration: BoxDecoration(
                                    color: _darkTheme
                                        ? Color(0xFF2a4848)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "You don't have any saved statistics",
                                        style: TextStyle(
                                            color: _darkTheme
                                                ? Colors.white
                                                : Color(0xFF336666),
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w300,
                                            fontSize: _height * 0.021),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Color(0xFF669999)),
                      ));
                    }
                  }),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              leading: Container(
                margin: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/app_logo_w.png"),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                PopupMenuButton<String>(
                  offset: Offset(0, 5),
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut(); //callback
    } catch (e) {
      print(e);
    }
  }

  void _choiceAction(String choice) {
    if (choice == Constants.SIGN_OUT) _signOut();
  }

  Widget cardMore(index, list, _darkTheme, _height, _width) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 15.0),
          child: Divider(
            color: _darkTheme ? Colors.white : Color(0xFF717e81),
            height: 5.0,
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              top: _height * 0.012, right: 15.0, bottom: _height * 0.018),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Weaving",
                      style: TextStyle(
                          color: _darkTheme ? Colors.white : Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                    Text(
                      list[index]['weaving'].toString(),
                      style: TextStyle(
                          color: getColor(list[index]['weaving']),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Swerving",
                      style: TextStyle(
                          color: _darkTheme ? Colors.white : Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                    Text(
                      list[index]['swerving'].toString(),
                      style: TextStyle(
                          color: getColor(list[index]['swerving']),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Sudden Braking",
                      style: TextStyle(
                          color: _darkTheme ? Colors.white : Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                    Text(
                      list[index]['suddenBraking'].toString(),
                      style: TextStyle(
                          color: getColor(list[index]['suddenBraking']),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Fast U-Turn",
                      style: TextStyle(
                          color: _darkTheme ? Colors.white : Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                    Text(
                      list[index]['fastUTurn'].toString(),
                      style: TextStyle(
                          color: getColor(list[index]['fastUTurn']),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: _height * 0.022),
                    ),
                  ],
                ),
              ]),
        ),
      ],
    );
  }
}
