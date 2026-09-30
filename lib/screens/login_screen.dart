import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'dart:async'; //3.1 importar libreria el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // ✅ Corregido el nombre del constructor

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  // 1.1 Crear el cerebro de la animacion
  StateMachineController? _controller;
  // SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  //Variable del recorrido de la mirada
  SMINumber? _numLook;
  // 3.3 Variable para el timer al dejaer de escribir
  Timer? _TypingDebunce;

  // 2.1 Crear variables de foco
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // 2.2 Listeners
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_isHandsUp != null) {
        _isHandsUp?.change(false);
        //3.4 mirada neutra
        _numLook?.value = 50;
      }
    });

    _passwordFocus.addListener(() {
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para evitar pantalla negra
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            // Añadido para evitar desbordamientos de pantalla
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/bimbo.riv',
                    stateMachines: ['Login Machine'],
                    // 1.2 Vincular animacion
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      // 1.3 Verificar que inicio bien
                      if (_controller == null) return;
                      artboard.addController(_controller!);

                      // Vinculamos variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      //3.5 Vinculamos la variable de mirada
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                SizedBox(height: 10),

                // Campo Email
                TextField(
                  focusNode: _emailFocus,
                  onChanged: (value) {
                    if (_isChecking == null) return;
                    _isChecking!.change(true);

                    //3.6 implementar un numlook
                    // ajustes de limites de 0 a 100
                    // 80 medida de calibracion
                    final look = (value.length / 80.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    //clamp es el rango
                    _numLook?.value = look;
                    //3.7 debounce para que deje de mirar cuando deja de escribir
                    _TypingDebunce?.cancel();
                    _TypingDebunce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Campo Password
                TextField(
                  focusNode: _passwordFocus,
                  onChanged: (value) {
                    if (_isHandsUp == null) return;
                    _isHandsUp!.change(true);
                  },
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _TypingDebunce?.cancel(); //3.9 Cancelar el timer si está activo
    super.dispose();
  }
}
