import 'package:flutter/material.dart';

class LogInButton extends StatelessWidget {
  const LogInButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFDF8600)),
        child: SizedBox(
            height: 70,
            width: double.infinity,
            child: Center(
              child: Text(text, style: TextStyle(color: Colors.white)),
            )));
  }
}
