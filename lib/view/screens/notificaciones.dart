import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alumnoProvider = context.watch<AlumnoProvider>();
    return Column(
      children: [
        const Center(
            child: Text('Notificaciones', style: TextStyle(fontSize: 24))),
        Expanded(
          child: alumnoProvider.notificaciones.isEmpty
              ? Column(
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
                    const Text(
                      'Aún no hay notificaciones, pero aparecerán aquí en cuanto las haya.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: alumnoProvider.notificaciones.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      title: Text(alumnoProvider.notificaciones[index].titulo ??
                          'Sin título'),
                      subtitle:
                          Text(alumnoProvider.notificaciones[index].fecha!),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              alumnoProvider.notificaciones[index].texto!,
                            ),
                          ),
                        )
                      ],
                    );
                  }),
        ),
      ],
    );
  }
}
