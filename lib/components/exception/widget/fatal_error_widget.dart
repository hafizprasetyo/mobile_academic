import 'package:flutter/material.dart';

class FatalErrorWidget extends StatelessWidget {
  final String buttonText;
  final void Function() onButtonPressed;

  FatalErrorWidget(this.buttonText, this.onButtonPressed);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      minimumSize: Size(88, 44),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Colors.blue,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/images/fatal_error.png",
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.15,
          left: MediaQuery.of(context).size.width * 0.3,
          right: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 13),
                  blurRadius: 25,
                  color: Color(0xFF5666C2).withOpacity(0.17),
                ),
              ],
            ),
            child: TextButton(
              style: flatButtonStyle,
              child: Text(buttonText),
              onPressed: onButtonPressed,
            ),
          ),
        )
      ],
    );
  }
}
