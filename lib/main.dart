import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'appauth.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

void main() async {
  //async lo vuelve asincronico. Espera
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      DataProvider.instance.updateUserData(user);
      DataProvider.instance.updateNotificationsToken();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C00CE), secondary: const Color(0xFFFF7A00)),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.light,
      title: 'Excluidos Unidos',
      home: const AppAuthWrapper(), //en login.dart primer ventana a abrirse
    );
  }
}

//      appBar: AppBar(
//      backgroundColor: Color.fromARGB(255, 166, 3, 243),
//    title: const Text('Eu!'),
//  style: TextStyle(fontWeight: FontWeight.bold)
