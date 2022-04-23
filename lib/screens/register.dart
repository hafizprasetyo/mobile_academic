import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/components/forms/email_input.dart';
import 'package:academic/components/forms/fullname_input.dart';
import 'package:academic/components/forms/password_input.dart';
import 'package:academic/components/forms/username_input.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/screens/login.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = new GlobalKey<FormBuilderState>();
  final _dataAuthenticationRepository = new DataAuthenticationRepository();
  bool _progressIndicator = false;

  void _showProgress(bool state) {
    setState(() {
      _progressIndicator = state;
    });
  }

  _gotoSignIn() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  _gotoException(dynamic error) {
    return Navigator.of(this.context).pushReplacement(MaterialPageRoute(
      builder: (_) => ExceptionScreen(
        exception: error,
        redirectScreen: this.widget,
      ),
    ));
  }

  Future _signUp() async {
    _showProgress(true);

    try {
      await _dataAuthenticationRepository.register(
        fullName: _formKey.currentState!.value[Constants.fullnameField] ?? '',
        username: _formKey.currentState!.value[Constants.usernameField] ?? '',
        email: _formKey.currentState!.value[Constants.emailField] ?? '',
        password: _formKey.currentState!.value[Constants.passwordField] ?? '',
      );

      List<Widget> messages = [Text(Strings.gotoSignIn)];
      if (await _dataAuthenticationRepository.validateMailStatus()) {
        messages = [
          Text(
            Strings.checkEmail.replaceAll(
              '{email}',
              _formKey.currentState!.value[Constants.emailField],
            ),
          ),
          Text(Strings.gotoSignIn)
        ];
      }

      _showProgress(false);
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Text(Strings.registrationSuccessful),
          content: SingleChildScrollView(
            child: ListBody(children: messages),
          ),
          actions: [
            TextButton(
              onPressed: () => _gotoSignIn(),
              child: Text(Labels.continue_step.toUpperCase()),
            )
          ],
        ),
      );
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
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => _gotoSignIn(),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 420,
                ),
                padding: EdgeInsets.all(25),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Registrasi Akun',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Silahkan isi formulir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(child: FullNameInput()),
                      SizedBox(height: 10),
                      Container(child: UsernameInput()),
                      SizedBox(height: 10),
                      Container(child: EmailInput()),
                      SizedBox(height: 10),
                      Container(child: PasswordInput()),
                      SizedBox(height: 20),
                      // TOMBOL SUBMIT
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: primaryButton(
                          context: context,
                          label: Labels.forward_step.toUpperCase(),
                          onPressed: () {
                            FocusScope.of(this.context).unfocus();
                            if (_formKey.currentState!.saveAndValidate())
                              _signUp();
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _signInButton(),
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

  Widget _signInButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah terdaftar?',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () => _gotoSignIn(),
          child: Text(
            'Masuk',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
