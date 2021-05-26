import 'dart:async';
import 'dart:developer';

import 'package:BloomZon/UI/BzWebview.dart';
import 'package:BloomZon/helpers/authhelper.dart';
import 'package:BloomZon/utils/DxNetwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BloomZon/UI/BottomNavigationBar.dart';
import 'package:BloomZon/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:BloomZon/UI/HomeUIComponent/Home.dart';
import 'package:BloomZon/UI/LoginOrSignup/Login.dart';
import 'package:BloomZon/UI/OnBoarding.dart';

/// Run first apps open
void main() {
  runApp(myApp());
}

/// Set orienttation
class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return new MaterialApp(
      title: "BloomZon",
      theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          primaryColorLight: Colors.white,
          primaryColorBrightness: Brightness.light,
          primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      /// Move splash screen to ChoseLogin Layout
      /// Routes
      routes: <String, WidgetBuilder>{
        "onBoarding": (BuildContext context) => new onBoarding(),
        "login": (BuildContext context) => new loginScreen(),
        "home": (BuildContext context) =>  new BzWebView(data: {'url':"${DxNet.baseUrl}?"},)

      },
    );
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {
  @override
  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }
  /// To navigate layout change
  void NavigatorPage() {

    xFirstTimexLogin().then((value) {
      if (value['notFirstTime'] == true && value['isLoggedIn'] == true) {
          Navigator.of(context).pushReplacementNamed("home");
          return;
      }
      else if(value['notFirstTime'] == true && value['isLoggedIn'] == false){
        Navigator.of(context).pushReplacementNamed("login");
        return;
      }else{
        sFirstTime().then((value) =>
            Navigator.of(context).pushReplacementNamed("onBoarding")
        );
    }}
    );
  }
  /// Declare startTime to InitState
  @override
  void initState() {
    super.initState();
    startTime();
  }
  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/man.png'), fit: BoxFit.cover)),
        child: Container(
          /// Set gradient black in image splash screen (Click to open code)
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.3),
                    Color.fromRGBO(0, 0, 0, 0.4)
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      child: Image.asset("assets/blogo.png",fit: BoxFit.contain,),
                    ),
                    /// Text header "Welcome To" (Click to open code)
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Sans",
                        fontSize: 19.0,
                      ),
                    ),
                    /// Animation text BloomZon to choose Login with Hero Animation (Click to open code)
                    Hero(
                      tag: "Bloomzon",
                      child: Text(
                        "BloomZon",
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 35.0,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
