import 'package:flash_chat_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  late String buttonTitle;
  late Color buttonColor;
  late final void Function() onPressed;

  RoundedButton(
      {required this.buttonTitle,
      required this.buttonColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            buttonTitle,
          ),
        ),
      ),
    );
  }
}
