import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:prueba_01/screens/home.dart';
import 'package:prueba_01/screens/log_in_screens/first_launch.dart';

class AppAuthWrapper extends StatefulWidget {
  const AppAuthWrapper({super.key});

  @override
  State<AppAuthWrapper> createState() => _AppAuthWrapperState();
}

class _AppAuthWrapperState extends State<AppAuthWrapper> {
  late Stream<User?> stream;

  @override
  void initState() {
    stream = FirebaseAuth.instance.authStateChanges(); //envia estado de inicio de sesion
    super.initState(); //estado inicial del widget
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: stream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          // User is signed in.
          return const HomePage();
        } else {
          // User is not signed in.
          return const LogInPage();
        }
      },
    );
  }
}
