import 'package:flutter/material.dart';

class MantenimientoScreen extends StatelessWidget {
  const MantenimientoScreen({super.key});
  static const String route = 'mantenimiento_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 210,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/logo.png'),
                //fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
              "Estamos realizando tareas de mantenimiento.\n\nLa aplicación estará temporalmente fuera de servicio para mejorar su funcionamiento.\n\nVolverá a estar disponible en breve.\n\nGracias por su comprensión.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
