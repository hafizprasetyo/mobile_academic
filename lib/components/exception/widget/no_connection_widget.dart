import 'package:flutter/material.dart';

class NoConnectionWidget extends StatelessWidget {
  final String buttonText;
  final void Function() onButtonPressed;

  NoConnectionWidget(this.buttonText, this.onButtonPressed);

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
          "assets/images/no_connection.png",
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 100,
          left: 30,
          child: TextButton(
            style: flatButtonStyle,
            child: Text(buttonText),
            onPressed: onButtonPressed,
          ),
        )
      ],
    );
  }
}
