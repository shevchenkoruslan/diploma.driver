import 'package:flutter/material.dart';
import 'package:driver/services/firebaseAuthUtils.dart';

class SignInSignUpPage extends StatefulWidget {
  SignInSignUpPage({this.auth, this.onSignedIn});

  final AuthFunc auth;
  final VoidCallback onSignedIn;

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _email, _password, _errorMessage, _name;
  bool _isIos,
      _isLoading,
      _isSignInForm,
      _isResetForm,
      _showForgotPassword,
      _obscurePassword;
  var _width, _height;

// Check if form is valid before perform login or signup
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

// Perform sign in/sign up
  Future<String> _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_isSignInForm) {
          userId = await widget.auth.signIn(_email, _password);
        } else if (_isResetForm) {
          await widget.auth.sendPasswordResetEmail(_email);
        } else {
          userId = await widget.auth.signUp(_name, _email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _isSignInForm)
          widget.onSignedIn();
      } catch (e) {
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

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    _isLoading = false;
    _isSignInForm = true;
    _isResetForm = false;
    _showForgotPassword = true;
    _obscurePassword = true;
  }

  void toggleForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _isSignInForm = !_isSignInForm;
      _showForgotPassword = !_showForgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    print(_width);
    print(_height);
    return Scaffold(
      backgroundColor: Color(0xFFE6E6E6),
      body: Stack(
        children: <Widget>[
          showBody(),
          showCircularProgress(),
        ],
      ),
    );
  }

  void _showVerifyEmailSentDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2a4848),
            title: Text('Verify your account'),
            content: Text('Link verify has been sent to your email'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  toggleForm();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
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

  showBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            _showText(),
            _showNameInput(),
            _isResetForm ? _showEmailInput(false) : _showEmailInput(true),
            _isResetForm ? _showEmailInput(true) : _showPasswordInput(),
            _showForgotPasswordButton(),
            _showButton(),
            _showSecondaryButton(),
            _showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Container(
        child: Text(
          _errorMessage,
          textAlign: TextAlign.center,
          maxLines: 5,
          style: TextStyle(
              fontSize: _height * 0.017,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  Widget _showSecondaryButton() {
    return Container(
      child: FlatButton(
        onPressed: () {
          if (_isResetForm == true) _isResetForm = false;
          toggleForm();
          // Dismiss the keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Text(
            _isSignInForm
                ? "Create an account"
                : _isResetForm ? "Back to sign in" : "Have an account? Sign In",
            style: TextStyle(
                fontSize: _height * 0.022,
                fontWeight: FontWeight.w300,
                fontFamily: "Montserrat",
                color: Color(0xFF666666))),
      ),
    );
  }

  Widget _showButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, _height * 0.054, 0.0, 0.0),
      child: SizedBox(
        height: _height * 0.048,
        child: Builder(
          builder: (context) => RaisedButton(
            onPressed: () {
              _validateAndSubmit().then((_err) {
                if (_isResetForm && _email != null && _err == "") {
                  setState(() {
                    _isSignInForm = true;
                    _isResetForm = !_isResetForm;
                    _showForgotPassword = true;
                  });
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text("A password reset link has been sent to $_email"),
                    duration: const Duration(seconds: 3),
                  ));
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
              _isSignInForm ? "SIGN IN" : _isResetForm ? "SUBMIT" : "SIGN UP",
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

  _showPasswordInput() {
    return Visibility(
      child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, _height * 0.018, 0.0, 0.0),
          child: Container(
            height: _height * 0.048,
            child: TextFormField(
              maxLines: 1,
              obscureText: _obscurePassword,
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
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFF3C5859))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFF999999))),
                  hintText: "Enter password",
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: _height * 0.018,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w300,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: _height * 0.024,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: _height * 0.024,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      })),
              validator: (value) =>
                  value.isEmpty ? "Password can not be empty" : null,
              onSaved: (value) => _password = value.trim(),
            ),
          )),
      visible: !_isResetForm,
    );
  }

  Widget _showForgotPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Visibility(
          child: Container(
            height: _height * 0.06,
            child: _showForgotPassword
                ? FlatButton(
                    padding: EdgeInsets.only(right: 0.0),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          fontSize: _height * 0.019,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Montserrat",
                          color: Color(0xFF666666)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isResetForm = true;
                        _isSignInForm = false;
                        _showForgotPassword = !_showForgotPassword;
                      });
                    })
                : null,
          ),
        ),
      ],
    );
  }

  _showEmailInput(bool shouldShow) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, _height * 0.018, 0.0, 0.0),
        child: Container(
          height: _height * 0.048,
          child: shouldShow
              ? TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(0xFF999999),
                  autofocus: false,
                  style: TextStyle(
                    color: Color(0xFF2a4848),
                    fontSize: _height * 0.018,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: _height * 0.018),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFF3C5859))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFF999999))),
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
                        size: _height * 0.019,
                      )),
                  validator: (value) =>
                      value.isEmpty ? "Email can not be empty" : null,
                  onSaved: (value) => _email = value.trim(),
                )
              : null,
        ));
  }

  _showNameInput() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, _height * 0.17, 0.0, 0.0),
        child: Container(
            height: _height * 0.048,
            child: (!_isSignInForm && !_isResetForm)
                ? TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    cursorColor: Color(0xFF999999),
                    style: TextStyle(color: Color(0xFF2a4848)),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: _height * 0.018),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Color(0xFF3C5859))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Color(0xFF999999))),
                        hintText: "Enter name",
                        hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: _height * 0.019,
                            fontFamily: "Montserrat-Medium"),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: _height * 0.019,
                        )),
                    validator: (value) =>
                        value.isEmpty ? "Name can not be empty" : null,
                    onSaved: (value) => _name = value.trim(),
                  )
                : null)); // Empty view
  }

  _showText() {
    return Hero(
      tag: 'here',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, _height * 0.03, 0.0, 0.0),
        child: Center(
          child: Text(
            "EasyDrive",
            style: TextStyle(
                fontSize: _height * 0.023,
                color: Color(0xFF2A4848),
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  _showLogo() {
    return Container(
      width: _width * 0.286,
      height: _height * 0.12,
      margin: EdgeInsets.fromLTRB(0.0, _height * 0.09, 0.0, 0.0),
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('images/app_logo.png')),
      ),
    );
  }
}
