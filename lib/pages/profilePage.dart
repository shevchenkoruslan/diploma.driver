import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToEditArgs.dart';
import 'package:driver/constants/constants.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/icons/custom_icons_icons.dart';
import 'package:driver/pages/editPage.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _name, _email;
  bool _darkTheme = false;
  bool _autoSave = false;
  File imageFile;
  var imageUrl;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _autoSave = prefs.getBool('autoSave') ?? false;
        });
      }
    });
  }

  _uploadImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        imageFile = image;
      });
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(widget.userId);
      StorageUploadTask uploadTask = storageReference.putFile(image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Firestore.instance
          .collection("users")
          .document(widget.userId)
          .updateData(({"image": downloadUrl}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/road.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(top: _height * 0.048),
                  color: Colors.transparent,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              height: _height * 0.06,
                              width: _width * 0.128,
                              decoration: BoxDecoration(
                                color: _darkTheme
                                    ? Color(0xFF666666)
                                    : Color(0xFFe6e6e6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                  icon: Icon(
                                    CustomIcons.edit,
                                    color: _darkTheme
                                        ? Color(0xFFe6e6e6)
                                        : Color(0xFF666666),
                                    size: 20.0,
                                  ),
                                  onPressed: () => _navigate(context)),
                            ),
                            Container(
                              height: _height * 0.139,
                              width: _width * 0.293,
                              decoration: BoxDecoration(
                                color: _darkTheme
                                    ? Color(0xFF666666)
                                    : Color(0xFFe6e6e6),
                                shape: BoxShape.circle,
                              ),
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: Firestore.instance
                                      .collection("users")
                                      .document(widget.userId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return GestureDetector(
                                        child: snapshot.data['image'] == null
                                            ? IconButton(
                                                alignment: Alignment.center,
                                                icon: Icon(
                                                  CustomIcons.person,
                                                  color: _darkTheme
                                                      ? Color(0xFFe6e6e6)
                                                      : Color(0xFF666666),
                                                  size: _height * 0.077,
                                                ),
                                                onPressed: () {
                                                  _uploadImage(
                                                      ImageSource.gallery);
                                                })
                                            : CircleAvatar(
                                                backgroundColor: _darkTheme
                                                    ? Color(0xFF666666)
                                                    : Color(0xFFe6e6e6),
                                                backgroundImage: NetworkImage(
                                                    snapshot.data['image']),
                                              ),
                                        onTap: () {
                                          _uploadImage(ImageSource.gallery);
                                        },
                                      );
                                    } else {
                                      return Container(
                                        color: Colors.white,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF669999)),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            Container(
                              height: _height * 0.06,
                              width: _width * 0.128,
                              decoration: BoxDecoration(
                                color: _darkTheme
                                    ? Color(0xFF666666)
                                    : Color(0xFFe6e6e6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                  icon: Icon(
                                    CustomIcons.camera,
                                    color: _darkTheme
                                        ? Color(0xFFe6e6e6)
                                        : Color(0xFF666666),
                                  ),
                                  onPressed: () {
                                    _uploadImage(ImageSource.camera);
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(height: _height * 0.024),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  StreamBuilder<DocumentSnapshot>(
                                      stream: Firestore.instance
                                          .collection("users")
                                          .document(widget.userId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          _name = snapshot.data["name"];
                                          _email = snapshot.data["email"];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Center(
                                                child: Text(
                                                  snapshot.data["name"],
                                                  style: TextStyle(
                                                      color: Color(0xFF2a4848),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize:
                                                          _height * 0.022),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  snapshot.data["email"],
                                                  style: TextStyle(
                                                      color: Color(0xFF2a4848),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize:
                                                          _height * 0.022),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          return Container(
                                            color: Colors.transparent,
                                          );
                                        }
                                      }),
                                ]),
                          ],
                        ),
                      ]),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: _width,
                  color: _darkTheme ? Color(0xFF666666) : Colors.white,
                  child: Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(top: _height * 0.024),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: Text(
                                "Dark Mode",
                                style: TextStyle(
                                    color: _darkTheme
                                        ? Colors.white
                                        : Color(0xFF336666),
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w300,
                                    fontSize: _height * 0.022),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Switch(
                                value: _darkTheme,
                                onChanged: (value) {
                                  setState(() {
                                    _darkTheme = value;
                                  });
                                  onThemeChanged(value, themeNotifier);
                                },
                                inactiveTrackColor: Color(0xFFcccccc),
                                inactiveThumbColor: Color(0xFF999999),
                                activeTrackColor: Color(0xFF669999),
                                activeColor: Color(0xFF336666),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: Text(
                                "Autosave",
                                style: TextStyle(
                                    color: _darkTheme
                                        ? Colors.white
                                        : Color(0xFF336666),
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w300,
                                    fontSize: _height * 0.022),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Switch(
                                value: _autoSave,
                                onChanged: (value) {
                                  setState(() {
                                    _autoSave = value;
                                  });
                                  onAutoSaveChanged(value);
                                },
                                inactiveTrackColor: Color(0xFFcccccc),
                                inactiveThumbColor: Color(0xFF999999),
                                activeTrackColor: Color(0xFF669999),
                                activeColor: Color(0xFF336666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context) async {
    final data = await Navigator.pushNamed(context, EditPage.routeName,
        arguments: PassToEditArgs(widget.auth, widget.userId, _name, _email));
    if (data != null)
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            backgroundColor: Color(0xFF99CCCC),
            content: Text(
              "$data",
              style: TextStyle(
                  color: Color(0xFF2a4848),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.of(context).size.height * 0.019),
            ),
            duration: const Duration(seconds: 1)));
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

void onThemeChanged(bool value, ThemeNotifier themeNotifier) {
  (value)
      ? themeNotifier.setTheme(darkTheme)
      : themeNotifier.setTheme(lightTheme);
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('darkMode', value);
  });
}

void onAutoSaveChanged(bool value) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('autoSave', value);
  });
}
