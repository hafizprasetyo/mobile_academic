import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/components/forms/password_input.dart';
import 'package:academic/components/forms/uname_input.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/screens/register.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';

import 'menu/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = new GlobalKey<FormBuilderState>();
  final _dataAuthenticationRepository = new DataAuthenticationRepository();

  late bool _progressIndicator;

  @override
  void initState() {
    super.initState();
    _progressIndicator = false;
    _logout();
  }

  void _showProgress(bool state) {
    setState(() {
      _progressIndicator = state;
    });
  }

  _gotoSignUp() {
    return Navigator.push(
      this.context,
      PageTransition(
        child: RegisterScreen(),
        type: PageTransitionType.fade,
      ),
    );
  }

  _gotoHome(User user) {
    return Navigator.pushReplacement(
      this.context,
      PageTransition(
        child: MenuScreen(user: user),
        type: PageTransitionType.fade,
      ),
    );
  }

  _gotoException(dynamic error) {
    return Navigator.of(this.context).pushReplacement(MaterialPageRoute(
      builder: (_) => ExceptionScreen(
        exception: error,
        redirectScreen: this.widget,
      ),
    ));
  }

  Future _logout() async {
    try {
      await _dataAuthenticationRepository.logout();
    } catch (e) {
      return _gotoException(e);
    }
  }

  Future _signIn({int maximumTry = 3}) async {
    _showProgress(true);

    try {
      // pastikan percobaan masuk tidak melebihi batas yang ditentukan
      if (maximumTry < 1) throw Exception(Strings.signInOverTry);

      // lakukan panggilan otentikasi
      await _dataAuthenticationRepository.authenticate(
        email: _formKey.currentState!.value[Constants.unameField] ?? '',
        password: _formKey.currentState!.value[Constants.passwordField] ?? '',
      );

      // pastikan otentikasi dan teruskan ke halaman utama,
      // atau lanjutkan metode jika belum ter-otentikasi
      if (await _dataAuthenticationRepository.isAuthenticated()) {
        // Ambil data di local storage
        User user = await _dataAuthenticationRepository.getCurrentUser();

        // alihkan ke halaman utama
        _showProgress(false);
        return _gotoHome(user);
      }

      // ulangi otentikasi melalui panggilan metode yang
      // sama dan kurangi batas maksimal percobaan
      _signIn(maximumTry: maximumTry - 1);
    } on APIException catch (e) {
      _showProgress(false);
      return new ExceptionDialog(screenContext: context).apiErrors(e);
    } catch (e) {
      _showProgress(false);
      return _gotoException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      opacity: 1.0,
      inAsyncCall: _progressIndicator,
      progressIndicator: progressIndicator(),
      child: GestureDetector(
        onTap: () => FocusScope.of(this.context).unfocus(),
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 420,
                ),
                padding: EdgeInsets.all(25),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 26,
                          letterSpacing: 1.5,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Pejuang ${Constants.companyName} !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 50),
                      Container(child: UnameInput()),
                      SizedBox(height: 10),
                      Container(child: PasswordInput()),
                      SizedBox(height: 20),
                      // TOMBOL SUBMIT
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: flatButton(
                          label: 'TERUSKAN IDENTITAS',
                          onPressed: () {
                            FocusScope.of(this.context).unfocus();
                            if (_formKey.currentState!.saveAndValidate())
                              _signIn();
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _signUpButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum terdaftar?',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () => _gotoSignUp(),
          child: Text(
            'Registrasi',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
