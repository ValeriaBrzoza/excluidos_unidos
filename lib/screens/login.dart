import 'package:flutter/material.dart';
import 'package:prueba_01/widgets/botones.dart';
import 'package:prueba_01/screens/home.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFA603F3),
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.5,
              child: Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Eu!',
                    style: TextStyle(color: Colors.white, fontSize: 80, fontFamily: 'Jua'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogInWithGoogle(
                      text: 'Log in with Google',
                      onPressed: () {},
                    ),
                    SizedBox(height: 50),
                    LogInWithGoogle(
                      text: 'Continue as guest',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
