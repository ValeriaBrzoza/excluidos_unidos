import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogInButton extends StatelessWidget {
  const LogInButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttonColor,
  });
  final Color buttonColor;
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
        child: SizedBox(
            height: 70,
            width: double.infinity,
            child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: Get.isDarkMode ? Colors.black87 : Colors.white)),
            )));
  }
}
