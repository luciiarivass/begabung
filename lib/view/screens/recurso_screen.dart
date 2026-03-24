import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:begabung_app/view/providers/recurso_provider.dart';
import 'package:begabung_app/view/screens/recursos_alumno_screen.dart';
import 'package:begabung_app/view/screens/recursos_profesional_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final alumnoProvider = context.watch<AlumnoProvider>();
    final profesionalProvider = context.watch<ProfesionalProvider>();
    final recursoProvider = context.watch<RecursoProvider>();

    /// Si es alumno → pantalla alumno
    if (alumnoProvider.alumno != null) {
      return RecursosAlumnoScreen(
        alumno: alumnoProvider.alumno!,
      );
    }

    /// Si es profesional → pantalla profesional
    if (profesionalProvider.profesional != null) {
      return const RecursosProfesionalScreen();
    }

    /// Pantalla genérica si no hay recursos o usuario aún cargando
    if (recursoProvider.recursos.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Recursos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 210,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/images/logo.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Todavía no se ha publicado ningún recurso.\nCuando haya material disponible aparecerá aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}