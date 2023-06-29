import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/widgets/botones.dart';
import 'package:excluidos_unidos/screens/home.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeColors = Theme.of(context).colorScheme;
    return Scaffold(
      //devuelve vista
      backgroundColor: themeColors.primary,
      body: SizedBox(
        //caja, solo podemos darle tamaño
        height: size.height,
        child: Stack(
          //child de caja, lo que contiene la caja
          children: [
            //lo que contiene el stack, va a apilarse
            SizedBox(
              height: size.height * 0.5,
              child: Center(
                //centra :)
                child: RichText(
                  //permite textos con diferentes cosas (tamaño, fuente, color)
                  text: const TextSpan(
                    //un richtext tiene un textspan. va a contener uno o mas text
                    text: 'Eu!', //con diferentes cosas
                    style: TextStyle(
                        color: Colors.white, fontSize: 80, fontFamily: 'Jua'),
                  ),
                ),
              ),
            ),
            Positioned(
              //esta dentro del stack, posicionado respecto stack
              top: 0, //stack ocupa toda la pantalla
              bottom: 0, //y este positioned tambien
              left: 0,
              right: 0,
              child: Padding(
                //borde en blanco
                padding: const EdgeInsets.all(8.0), //propiedad del borde
                child: Column(
                  //esto esta a 8 puntos de distancia entre todos los bordes
                  mainAxisAlignment: MainAxisAlignment
                      .center, //eje principal de la columna, .center porque lo queremos centrado
                  children: [
                    LogInButton(
                      //widget propio
                      text: 'Ingresar con Google',
                      onPressed: () {
                        if (kIsWeb) {
                          FirebaseAuth.instance
                              .signInWithRedirect(GoogleAuthProvider());
                        } else {
                          FirebaseAuth.instance
                              .signInWithProvider(GoogleAuthProvider());
                        }
                      },
                      buttonColor: themeColors.secondary,
                    ),
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
