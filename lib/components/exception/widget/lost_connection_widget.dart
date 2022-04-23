import 'package:flutter/material.dart';

class LostConnectionWidget extends StatelessWidget {
  final String buttonText;
  final void Function() onButtonPressed;

  LostConnectionWidget(this.buttonText, this.onButtonPressed);

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
          "assets/images/lost_connection.png",
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.12,
          left: MediaQuery.of(context).size.width * 0.065,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 5),
                  blurRadius: 25,
                  color: Color(0xFF59618B).withOpacity(0.17),
                ),
              ],
            ),
            child: TextButton(
              style: flatButtonStyle,
              child: Text(buttonText),
              onPressed: onButtonPressed,
            ),
          ),
        ),
      ],
    );
  }
}
