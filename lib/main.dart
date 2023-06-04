import 'package:flutter/material.dart';
import 'package:prueba_01/screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFA603F3)),
      ),
      home: LogInPage(),
    );
  }
}

//      appBar: AppBar(
  //      backgroundColor: Color.fromARGB(255, 166, 3, 243),
    //    title: const Text('Eu!'),
    //  style: TextStyle(fontWeight: FontWeight.bold)