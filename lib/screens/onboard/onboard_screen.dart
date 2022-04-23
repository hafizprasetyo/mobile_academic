import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/screens/login.dart';
import 'package:academic/screens/register.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/care_view.dart';
import 'components/center_next_button.dart';
import 'components/mood_diary_view.dart';
import 'components/relax_view.dart';
import 'components/splash_view.dart';
import 'components/top_back_skip_view.dart';
import 'components/welcome_view.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 8));
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ClipRect(
        child: Stack(
          children: [
            SplashView(
              animationController: _animationController!,
            ),
            Center(
              child: RelaxView(
                animationController: _animationController!,
              ),
            ),
            Center(
              child: CareView(
                animationController: _animationController!,
              ),
            ),
            Center(
              child: MoodDiaryView(
                animationController: _animationController!,
              ),
            ),
            Center(
              child: WelcomeView(
                animationController: _animationController!,
              ),
            ),
            TopBackSkipView(
              onBackClick: _onBackClick,
              onSkipClick: _onSkipClick,
              animationController: _animationController!,
            ),
            CenterNextButton(
              animationController: _animationController!,
              onNextClick: _onNextClick,
              onLoginClick: _onLoginClick,
            ),
          ],
        ),
      ),
    );
  }

  void _onSkipClick() {
    _animationController?.animateTo(0.8,
        duration: Duration(milliseconds: 1200));
  }

  void _onBackClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.0);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.2);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.6 &&
        _animationController!.value <= 0.8) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.8 &&
        _animationController!.value <= 1.0) {
      _animationController?.animateTo(0.8);
    }
  }

  void _onNextClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.8);
    } else if (_animationController!.value > 0.6 &&
        _animationController!.value <= 0.8) {
      _signUpClick();
    }
  }

  Future _gotoException(dynamic error) async {
    return Navigator.of(this.context).pushReplacement(MaterialPageRoute(
      builder: (_) => ExceptionScreen(
        exception: error,
        redirectScreen: this.widget,
      ),
    ));
  }

  Future _disableOnboard() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool(Constants.skipOnboardKey, true);
    } catch (e) {
      return _gotoException(e);
    }
  }

  _signUpClick() async {
    await _disableOnboard();
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(),
      ),
    );
  }

  _onLoginClick() async {
    await _disableOnboard();
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
  }
}
