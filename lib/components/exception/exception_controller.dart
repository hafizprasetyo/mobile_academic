import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';

import '../label_icon.dart';
import 'widget/fatal_error_widget.dart';
import 'widget/lost_connection_widget.dart';
import 'widget/request_timeout_widget.dart';

class ExceptionDialog {
  final BuildContext screenContext;

  ExceptionDialog({
    required this.screenContext,
  });

  apiErrors(APIException apiException, {String? buttonText}) {
    FToast fToast = new FToast();
    fToast.init(this.screenContext);

    Map<String, dynamic> messages = apiException.messages;
    IconData icon = Icons.warning;

    switch (apiException.error.toUpperCase()) {
      case Initials.invalidInput:
        icon = Icons.block;
        break;
      case Initials.unknownAccount:
        icon = Icons.person_outline;
        break;
      case Initials.wrongPassword:
        icon = Icons.vpn_key;
        break;
      case Initials.accessDenied:
        icon = Icons.not_interested;
        break;
      case Initials.incompleteParams:
        icon = Icons.cancel_presentation_rounded;
        break;
      default:
        // TANGANI KESALAHAN TIDAK DIKENAL
        return fToast.showToast(
          child: failedToast(message: "Kesalahan tidak dikenal!"),
        );
    }

    return showDialog(
      barrierDismissible: false,
      context: this.screenContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: LabelIcon(
            label: "Informasi Peringatan",
            icon: Icons.info_outline_rounded,
            color: AppTheme.normalText,
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: 360,
                child: ListView.separated(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: apiException.messages.length,
                  itemBuilder: (context, index) {
                    String key = messages.keys.elementAt(index);

                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 16,
                            color: AppTheme.deactivatedText,
                          ),
                          SizedBox(width: 5),
                          Flexible(child: Text(messages[key])),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, int) {
                    return Divider(height: 0);
                  },
                ),
              );
            },
          ),
          actions: <Widget>[
            flatButton(
              label: "MENGERTI",
              backgroundColor: AppTheme.mainBtn,
              onPressed: () => Navigator.pop(this.screenContext),
            ),
          ],
        );
      },
    );
  }

  defaultErrors(Map<String, dynamic> errors) {
    AlertDialog alert = AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: 300,
          height: 400,
          child: ListView.separated(
            itemCount: errors.length,
            itemBuilder: (BuildContext context, int index) {
              String key = errors.keys.elementAt(index);
              String message = errors[key].toString();

              return ListTile(title: Text(message));
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          ),
        ),
      ),
    );

    return showDialog(context: this.screenContext, builder: (context) => alert);
  }
}

class ExceptionScreen extends StatefulWidget {
  final dynamic exception;

  final String? buttonText;
  final Widget? redirectScreen;
  final void Function()? onButtonPressed;

  const ExceptionScreen({
    Key? key,
    required this.exception,
    this.buttonText,
    this.onButtonPressed,
    this.redirectScreen,
  }) : super(key: key);

  @override
  _ExceptionScreenState createState() => _ExceptionScreenState();
}

class _ExceptionScreenState extends State<ExceptionScreen> {
  _getNavigation(BuildContext context) {
    return widget.redirectScreen is Widget
        ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.redirectScreen!,
            ),
          )
        : Navigator.pop(context);
  }

  Widget initView() {
    String buttonText =
        widget.buttonText?.toUpperCase() ?? Labels.back.toUpperCase();

    if (widget.exception.runtimeType == SocketException) {
      return RequestTimeoutWidget(
        buttonText,
        () => widget.onButtonPressed ?? _getNavigation(context),
      );
    } else if (widget.exception.runtimeType == TimeoutException) {
      return RequestTimeoutWidget(
        buttonText,
        () => widget.onButtonPressed ?? _getNavigation(context),
      );
    } else if (widget.exception.runtimeType == http.ClientException) {
      return LostConnectionWidget(
        buttonText,
        () => widget.onButtonPressed ?? _getNavigation(context),
      );
    }

    return FatalErrorWidget(
      buttonText,
      () => widget.onButtonPressed ?? _getNavigation(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: initView());
  }
}
