import 'package:driver/constants/themeConstants.dart';
import 'package:driver/icons/custom_icons_icons.dart';
import 'package:driver/pages/editPage.dart';
import 'package:driver/pages/profilePage.dart';
import 'package:driver/pages/sensorsPage.dart';
import 'package:driver/pages/statisticPage.dart';
import 'package:driver/pages/tripAnalysPage.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:driver/pages/signIn_signUp_Page.dart';
import 'package:driver/pages/homePage.dart';
import 'package:driver/enums/enums.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    var autoSaveOn = prefs.getBool('autoSave') ?? false;
    print(autoSaveOn);

    runApp(ChangeNotifierProvider(
        create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
        child: Consumer<ThemeNotifier>(
            builder: (context, ThemeNotifier notifier, child) {
          return MyApp();
        })));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: "EasyDrive",
        debugShowCheckedModeBanner: false,
        home: AppSplash(),
        theme: themeNotifier.getTheme(),
        routes: {
          TripAnalysPage.routeName: (context) => TripAnalysPage(),
          EditPage.routeName: (context) => EditPage(),
          SensorsPage.routeName: (context) => SensorsPage(),
        },
      ),
    );
  }
}

class AppSplash extends StatefulWidget {
  @override
  _AppSplashState createState() => _AppSplashState();
}

class _AppSplashState extends State<AppSplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: MyAppHome(auth: MyAuth()),
      title: Text(
        "EasyDrive",
        style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFF2A4848),
            fontFamily: "Montserrat",
            fontWeight: FontWeight.w900),
      ),
      image: Image(image: AssetImage("images/app_logo.png")),
      backgroundColor: Colors.white,
      loaderColor: Color(0xFF2a4848),
      photoSize: 65.0,
    );
  }
}

class MyAppHome extends StatefulWidget {
  MyAppHome({this.auth});

  final AuthFunc auth;

  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _showLoading();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return SignInSignUpPage(auth: widget.auth, onSignedIn: _onSignedIn);
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return DefaultTabController(
              length: 3,
              child: Scaffold(
                bottomNavigationBar: TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.home),
                      text: "Home",
                    ),
                    Tab(
                      icon: Icon(CustomIcons.bar),
                      text: "Statictic",
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: "Profile",
                    ),
                  ],
                  unselectedLabelColor: _darkTheme ?  Color(0xFF999999): Color(0xFF51544b),
                  indicatorColor: Colors.transparent,
                ),
                body: TabBarView(children: [
                  HomePage(
                      userId: _userId,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  StatisticPage(
                      userId: _userId,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  ProfilePage(
                      userId: _userId,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  // SensorsPage(),
                ]),
              ));
        } else
          return _showLoading();
        break;
      default:
        return _showLoading();
        break;
    }
  }

  void _onSignedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }
}

Widget _showLoading() {
  return Scaffold(
    body: Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF669999)),
      ),
    ),
  );
}