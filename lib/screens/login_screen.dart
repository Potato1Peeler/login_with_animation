import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // Al inicio la contraseña está oculta

  //Cerebro de la lógica de las animaciones (SMI: State Machine Input)
  StateMachineController? controller;
  SMIBool? isChecking; //Activa el modo chismoso
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; //Se emociona
  SMITrigger? trigFail; //Se pone sad
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
                    RiveAnimation.asset(
                      'assets/animated_login_character.riv',
                      stateMachines: ["Login Machine"],
                      //Al iniciarse
                      onInit: (artboard){
                        controller = StateMachineController.fromArtboard(artboard, "Login Machine");
                        if(controller == null) return;
                        artboard.addController(controller!);
                        isChecking = controller!.findSMI('isChecking');
                        isHandsUp = controller!.findSMI('isHandsUp');
                        trigSuccess = controller!.findSMI('trigSuccess');
                        trigFail = controller!.findSMI('trigFail');
                      },
                      )),
            //Espacio entre el oso y el texto email
            const SizedBox(
              height: 10,
            ),
            //Campo de texto del email
            TextField(
              onChanged: (value){
                if (isHandsUp != null){
                  //No tapar los ojos al escribir email
                  isHandsUp!.change(false);
                }
                if (isChecking == null) return;
                //Activa el modo chismoso
                isChecking!.change(true);
              },
              //Para que aparezca el @ en móviles
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
            //Campo de texto del password
            TextField(
              onChanged: (value){
                if (isChecking != null){
                  //No tapar los ojos al escribir email
                  isChecking!.change(false);
                }
                if (isHandsUp == null) return;
                //Activa el modo chismoso
                isHandsUp!.change(true);
              },
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
            ),
            const SizedBox(
              height: 10,
            ),
            //Texto "Forgot your Password?"
            SizedBox(
              width: size.width,
              child: Text(
                "Forgot your Password?",
                //Alinear a la derecha
                textAlign: TextAlign.right,
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            //Boton login
            const SizedBox(
              height: 10,
            ),
            //Boton estilo android
            MaterialButton(
              minWidth: size.width,
              height: 50,
              color: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onPressed: () {},
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ))
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
