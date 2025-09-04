import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // Al inicio la contraseña está oculta
  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      //Evita nudge o cámaras frontales para móviles
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          children: [
            SizedBox(
                width: size.width,
                height: 200,
                child:
                    RiveAnimation.asset('assets/animated_login_character.riv')),
            //Espacio entre el oso y el texto email
            const SizedBox(
              height: 10,
            ),
            //Campo de texto del email
            TextField(
              //Para que aparezza el @ en móviles
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(
                      //Esquinas redondeadas
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(
              height: 10,
            ),
            //Campo de texto del email
            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                      //Esquinas redondeadas
                      borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
      )),
    );
  }
}
