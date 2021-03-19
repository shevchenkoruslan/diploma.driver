import 'package:driver/arguments/passToTripAnalysArgs.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripAnalysPage extends StatefulWidget {
  static const routeName = '/trip-analys';
  @override
  _TripAnalysPageState createState() => _TripAnalysPageState();
}

class _TripAnalysPageState extends State<TripAnalysPage> {
  DateTime startTime, endTime;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _height = MediaQuery.of(context).size.height;
    final PassToTripAnalysArgs args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
        title: Text(
          "Trip",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: _height * 0.024),
        ),
        backgroundColor: Color(0xFFbdbfbe),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/road.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.07, 16.0, _height * 0.019),
              height: _height * 0.06,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Weaving",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.weaving.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Swerving",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.swerving.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sudden Braking",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.suddenBraking.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Fast U-turn",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.fastUTurn.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 60.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Total",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          (args.weaving +
                                  args.swerving +
                                  args.suddenBraking +
                                  args.fastUTurn)
                              .toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
