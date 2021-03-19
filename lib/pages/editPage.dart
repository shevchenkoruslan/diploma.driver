import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToEditArgs.dart';
import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  static const routeName = '/edit';

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading, _isIos;
  String _errorMessage, _newEmail, _newName;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  Future<String> _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          if (_isIos)
            _errorMessage = e.details;
          else
            _errorMessage = e.message;
        });
      }
    }
    return _errorMessage;
  }

  void _updateName(PassToEditArgs args) {
    try {
      Firestore.instance
          .collection('users')
          .document(args.userId)
          .updateData({'name': '$_newName'});
    } catch (e) {
      print(e.toString());
    }
  }

  void _updateEmail(PassToEditArgs args) {
    try {
      Firestore.instance
          .collection('users')
          .document(args.userId)
          .updateData({'email': '$_newEmail'});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    var _height = MediaQuery.of(context).size.height;
    final PassToEditArgs args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Color(0xFFe6e6e6),
      appBar: AppBar(
        backgroundColor: Color(0xFF2a4848),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: _height * 0.019),
        ),
      ),
      body: Stack(children: <Widget>[
        showBody(args, _height),
        showCircularProgress(),
      ]),
    );
  }

  showBody(PassToEditArgs args, double _height) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: _height * 0.036),
              child: TextFormField(
                initialValue: args.name,
                maxLines: 1,
                autofocus: false,
                cursorColor: Color(0xFF999999),
                style: TextStyle(
                  color: Color(0xFF2a4848),
                  fontSize: _height * 0.018,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: _height * 0.018),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF999999))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF3C5859))),
                    hintText: "Enter name",
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: _height * 0.018,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: _height * 0.027,
                    )),
                validator: (value) =>
                    value.isEmpty ? "Name can not be empty" : null,
                onSaved: (value) => _newName = value.trim(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _height * 0.018),
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                initialValue: args.email,
                autofocus: false,
                cursorColor: Color(0xFF999999),
                style: TextStyle(
                  color: Color(0xFF2a4848),
                  fontSize: _height * 0.018,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: _height * 0.018),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFF999999))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFF3C5859))),
                  hintText: "Enter email",
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: _height * 0.018,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w300,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey,
                    size: _height * 0.024,
                  ),
                ),
                validator: validateEmail,
                onSaved: (value) => _newEmail = value.trim(),
              ),
            ),
            showButton(args, _height),
          ],
        ),
      ),
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  showCircularProgress() {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF669999)),
        ),
      );
    return Container(height: 0.0, width: 0.0); // Empty view
  }

  Widget showButton(PassToEditArgs args, double _height) {
    return Container(
      margin: EdgeInsets.only(top: _height * 0.024),
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: _height * 0.048,
        child: Builder(
          builder: (context) => RaisedButton(
            onPressed: () {
              _validateAndSubmit().then((_err) {
                if (_err == "" && _newName != null && _newEmail != null) {
                  if (_newName != args.name) {
                    _updateName(args);
                  }
                  if (_newEmail != args.email) {
                    _updateEmail(args);
                  }
                  (_newName == args.name && _newEmail == args.email)
                      ? Navigator.pop(context)
                      : Navigator.pop(context, "Personal data changed");
                }
              });
              // Dismiss the keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Color(0xFF2A4848),
            child: Text(
              "CHANGE",
              style: TextStyle(
                  fontSize: _height * 0.017,
                  color: Colors.white,
                  fontFamily: "Palatino",
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}