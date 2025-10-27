import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//3.1 importar librería de Timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passToggle = true;

  //cerebro de la lógica de las animaciones
  StateMachineController? controller;
  //SMI: State Machine Input
  SMIBool? isChecking; // activa el modo chismoso
  SMIBool? isHandsUp; // se tapa los ojos
  SMITrigger? trigSuccess; // se emociona
  SMITrigger? trigFail; // se pone triste

  //2.1 variable para recorrido de la mirada
  SMINumber? numLook;

  // 1.1) FocusNode
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  //3.2 ) variable timer para detener la mirada al dejar de teclear
  Timer? _typingDebounce;

  // 4.1 declarar la variable "controller": controlar qué es lo que el usuario escribió y poder hacer algo con ello
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 errores para pintar (mostrar) en la UI
  String? emailError;
  String? passError;

  //Change - Variable para determinar el estado de carga
  bool isLoading = false;

  //4.3 validadores (características de función: tipo de retorno / nombre / lo que se va a recibir)
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  //Change - variables para tener match en la password
  bool hasMinLength(String pass) => pass.length >= 8;
  bool hasUpper(String pass) => RegExp(r'[A-Z]').hasMatch(pass);
  bool hasLower(String pass) => RegExp(r'[a-z]').hasMatch(pass);
  bool hasDigit(String pass) => RegExp(r'\d').hasMatch(pass);
  bool hasSpecial(String pass) => RegExp(r'[^A-Za-z0-9]').hasMatch(pass);

  //Change - Condiciones que nos devuelven el error actual unicamente
  String? getPasswordError(String pass) {
    if (pass.isEmpty) return 'La contraseña no puede estar vacía';
    if (!hasMinLength(pass)) return 'Debe tener al menos 8 caracteres';
    if (!hasUpper(pass)) return 'Debe incluir una mayúscula';
    if (!hasLower(pass)) return 'Debe incluir una minúscula';
    if (!hasDigit(pass)) return 'Debe incluir un número';
    if (!hasSpecial(pass)) return 'Debe incluir un caracter especial';
    return null;
  }

  // 4.4 darle acción al botón
Future<void> _onLogin() async {
  //Change - Evitar doble tap
  if (isLoading) return; 

  final email = emailCtrl.text.trim();
  final pass = passCtrl.text;

  //Change - Recalcular errores
  final eError = email.isEmpty
      ? 'El campo no puede estar vacío'
      : (!isValidEmail(email) ? 'Email inválido' : null);
  final pError = getPasswordError(pass);

  //4.5 para que se muestre en la ui el mensaje de error (Avisar que hubo un cambio)
  setState(() {
    emailError = eError;
    passError = pError;
  });

  //4.6 cerrar el teclado y bajar las manos al momento de enviar
  FocusScope.of(context).unfocus();
  _typingDebounce?.cancel();
  isChecking?.change(false);
  isHandsUp?.change(false);
  numLook?.value = 50.0; //mirada neutral

  setState(() {
    isLoading = true;
  });

  try {
    //Change - Delay de espera 
    await Future.delayed(const Duration(seconds: 2));

    //Change - Para verificar si hay errores
    final hasValidationErrors = eError != null || pError != null;

    if (hasValidationErrors) {
      //Change - Dependiendo si hay errores ejecutar fail
      trigFail?.fire();
    } else {
      //Change - Si no hay errores entonces ejecutar success
      final success = true;
      if (success) {
        trigSuccess?.fire();
      }
    }
  }  finally {
    //Change - Mostrar el boton de login (sin importar si hubo fail o success)
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  // 2.1) Listeners (oyentes/chismoso) escuchan todos los cambios que pasan
  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false); //Manos abajo cuando escribes el email
        //2.2 mirada neutral al enfocar e-mail (aún no se ha escrito nada)
        numLook?.value = 50.0;
        isHandsUp?.change(false);
      }
    });
    passFocus.addListener(() {
      //Manos arriba en password
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla del dispositivo (consulta el tamaño)
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  //al iniciarse
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                        artboard, "Login Machine");
                    //verificar que inició bien
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    //2.3 enlazar variable con la animación
                    numLook = controller!.findSMI('numLook');
                    //clamp
                  },
                ),
              ),
              //Espacio entre el oso y el texto email
              const SizedBox(
                height: 10,
              ),
              //Campo de texto del email
              TextField(
                //1.3asignas el focusNode al TextField
                //llamar al listener de email
                focusNode: emailFocus,
                //4.8 enlazar controller al TextField
                controller: emailCtrl,
                //2.4 implementando numLook
                onChanged: (value) {
                  //verificar que el usuario está escribiendo
                  isChecking!.change(true);
                  //ajuste de límites de 0 a 100 (definido por el creador de la animación)
                  //80 medida de calibración (depende del tamaño de la pantalla)
                  final look = (value.length / 80.0 * 100.0).clamp(
                      0.0, //limite inferior
                      100.0 //limite superior
                      ); //obtener la cantidad de caracteres puestos en el campo
                  numLook?.value = look;
                  //3.3 debounce: si vuelve a teclear, volver a fijar la mirada en el campo y reinicia el contador
                  _typingDebounce?.cancel(); //cancela cualquier timer existente
                  _typingDebounce =
                      Timer(const Duration(milliseconds: 3000), () {
                    if (!mounted) {
                      return; //si la pantalla se cierra
                    }
                    //mirada neutra
                    isChecking?.change(false);
                  });

                  //Change - Validación de email (muy parecida a la de password)
                  if (value.isEmpty) {
                    setState(() => emailError = null);
                  } else if (!isValidEmail(value)) {
                    setState(() => emailError = 'Email inválido');
                  } else {
                    setState(() => emailError = null);
                  }
                },
                //qué esperas en ese campo de texto (para que aparezca el @ en móviles)
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    //labelText: "E-mail", para que el hinttext pase arriba del campo de texto
                    hintText: "Email",
                    //4.9 mostrar el texto del error
                    errorText: emailError,
                    prefixIcon: const Icon(Icons.mail),
                    border: OutlineInputBorder(
                        //esquinas redondeadas
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(
                height: 10,
              ),

              //Campo de texto de contraseña
              TextField(
                focusNode: passFocus,
                //4.8 enlazar controller al TextField
                controller: passCtrl,
                onChanged: (value) {
                  if (isChecking != null) {
                    //corroborar que acá no se tapen los ojos al escribir el correo
                    //isHandsUp!.change(true);
                  }
                  if (isChecking == null) return;
                  //activa el modo chismoso
                  isChecking!.change(false);

                  //Change - Cambiar el estado para el error de la password en el cheklist
                  setState(() {
                    passError = getPasswordError(value);
                  });
                },
                //ocultar la contraseña
                obscureText: passToggle ? true : false,
                decoration: InputDecoration(
                    errorText: passError,
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    //widget de material que gestiona la interacción que tenemos, permitiendo cambiar de estado
                    //en este caso, cambiando el icono + si podemos o no ver la contraseña
                    suffixIcon: InkWell(
                      onTap: () {
                        if (passToggle == true) {
                          passToggle = false;
                        } else {
                          passToggle = true;
                        }
                        setState(() {});
                      },
                      child: passToggle
                          ? Icon(Icons.remove_red_eye)
                          : Icon(Icons.visibility_off),
                    ),
                    border: OutlineInputBorder(
                        //esquinas redondeadas
                        borderRadius: BorderRadius.circular(12))),
              ),
              //Change - Checklist a tiempo real
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheck(
                      'Mínimo 8 caracteres', hasMinLength(passCtrl.text)),
                  _buildCheck('Una mayúscula', hasUpper(passCtrl.text)),
                  _buildCheck('Una minúscula', hasLower(passCtrl.text)),
                  _buildCheck('Un número', hasDigit(passCtrl.text)),
                  _buildCheck(
                      'Un caracter especial', hasSpecial(passCtrl.text)),
                ],
              ),

              //Texto de 'olvidé la contraseña'
              SizedBox(height: 10),
              SizedBox(
                  width: size.width,
                  child: const Text(
                    'Forgot your password?',
                    //alinear a la derecha
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  )),
              //Botón login
              SizedBox(height: 10),
              //botón estilo Android
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                //4.10 llamar función de login
                //Change - Deshabilitar boton login si esta en cargando
                onPressed: isLoading ? null : _onLogin,
                //Change - Simbolo de circulo cargando para indicar que esta cargando
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Cargando",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          'Register',
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
        ),
      ),
    );
  }

  //Change - El simbolo de palomita si esta bien o de tacha si esta mal
  Widget _buildCheck(String text, bool ok) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  // 4.1) liberación de recursos /limpieza de focos
  @override
  void dispose() {
    //4.11 limpieza de los controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
