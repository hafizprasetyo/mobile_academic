import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/screens/login.dart';
import 'package:academic/screens/menu/menu_screen.dart';
import 'package:academic/screens/onboard/onboard_screen.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataAuthenticationRepository _dataAuthenticationRepository =
      new DataAuthenticationRepository();

  Map<String, dynamic>? _apiProfile;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _gotoException(dynamic error) {
    return Navigator.of(this.context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExceptionScreen(
          exception: error,
          redirectScreen: this.widget,
        ),
      ),
    );
  }

  Future _initialize() async {
    try {
      return await _fetchApiProfile().then(
        (value) => Future.delayed(
          Duration(seconds: 3),
          () async => await _gotoAfterSplash(),
        ),
      );
    } on APIException catch (e) {
      return new ExceptionDialog(screenContext: context).apiErrors(e);
    } catch (e) {
      return _gotoException(e);
    }
  }

  Future _gotoAfterSplash() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Widget defaultScreen;

      if (await _dataAuthenticationRepository.isAuthenticated()) {
        User user = await _dataAuthenticationRepository.getCurrentUser();
        defaultScreen = MenuScreen(user: user);
      } else if (preferences.getBool(Constants.skipOnboardKey) ?? false) {
        defaultScreen = LoginScreen();
      } else {
        defaultScreen = OnboardScreen();
      }

      return Navigator.pushReplacement(
        context,
        PageTransition(child: defaultScreen, type: PageTransitionType.fade),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchApiProfile() async {
    try {
      Map<String, dynamic> response =
          await HttpHelper.invokeHttp(Constants.baseEndpoint, RequestType.get);

      setState(() {
        _apiProfile = response;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TAMPILAN PROGRESS INDICATOR
    if (_apiProfile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 25),
              Text(
                Strings.loadConnection,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // TAMPILAN SPLASH SCREEN
    Map<String, dynamic> hostServer = _apiProfile!;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Image.asset(Constants.companyLogo, height: 160),
                  ),
                  SizedBox(height: 25),
                  Text(
                    Constants.companyName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    'Version ' + hostServer['apiVersion'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
