import 'package:flutter/material.dart';
import '../../widgets/botones.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key, required this.size, required this.themeColors});
  final Size size;
  final ColorScheme themeColors;

  @override
  Widget build(BuildContext context) {
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
                      text: 'Log in with Google',
                      onPressed: () {},
                      buttonColor: themeColors.secondary,
                    ),
                    const SizedBox(height: 50),
                    LogInButton(
                      //widget propio
                      text: 'Continue as guest',
                      onPressed: () {},
                      buttonColor: themeColors.secondary,
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
