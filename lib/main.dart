import 'package:flutter/material.dart';
import 'package:prueba_01/screens/log_in_screens/first_launch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8C00CE),
            secondary: const Color(0xFFFF7A00)),
      ),
      home: const LogInPage(), //en login.dart primer ventana a abrirse
    );
  }
}

//      appBar: AppBar(
//      backgroundColor: Color.fromARGB(255, 166, 3, 243),
//    title: const Text('Eu!'),
//  style: TextStyle(fontWeight: FontWeight.bold)
