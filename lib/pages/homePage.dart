import 'package:driver/arguments/passToSensorsArgs.dart';
import 'package:driver/constants/constants.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/pages/sensorsPage.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/road.jpg"), fit: BoxFit.fill)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  margin:
                      EdgeInsets.only(top: _height * 0.18, left: 20, right: 20),
                  decoration: BoxDecoration(
                      color: _darkTheme ? Color(0xFF336666) : Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Welcome on the board!",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          "Test your driving behavior!",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, SensorsPage.routeName, arguments: PassToSensorsArgs(widget.auth, widget.userId));
                    },
                    child: Container(
                      height: _height * 0.23,
                      margin: EdgeInsets.only(top: _height * 0.18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _darkTheme ? Color(0xFF3c5859) : Color(0xFFe6e6e6),
                      ),
                      child: Container(
                        height: _height * 0.21,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _darkTheme ? Color(0xFF336666) : Colors.white,
                          border: Border.all(
                            width: 1.0,
                            color: _darkTheme
                                ? Color(0xFF2a4848)
                                : Color(0xFF669999),
                          ),
                        ),
                        child: Center(
                            child: Text("START",
                                style: TextStyle(
                                    color: _darkTheme
                                        ? Colors.white
                                        : Color(0xFF336666),
                                    fontSize: _height * 0.03,
                                    fontFamily: "Palatino",
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ),
              ],
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
                          image: AssetImage("images/app_logo_w.png")))),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                PopupMenuButton<String>(
                  offset: Offset(0, 5),
                  onSelected: _choiceAction,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) _showVerifyEmailDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please verify your email'),
            content: Text('We need you verify email to continue use this app'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendVerifyEmail();
                },
                child: Text('Send me !'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Dismiss'),
              ),
            ],
          );
        });
  }

  void _sendVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thank you'),
            content: Text('Link verify has been sent to your email'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
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
}
