import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:begabung_app/view/widgets/starRating_widget.dart';
import 'package:begabung_app/view/widgets/starsstair_widget.dart';
import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EvaluacionesScreen extends StatelessWidget {
  const EvaluacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alumnoProvider = context.watch<AlumnoProvider>();
    return Column(
      children: [
        const Center(
            child: Text('Evaluaciones', style: TextStyle(fontSize: 24))),
        Expanded(
          child: alumnoProvider.evaluaciones.isEmpty
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
                      'Aún no hay evaluaciones para este alumno, pero aparecerán aquí en cuanto las haya.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: alumnoProvider.evaluaciones.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        title: Text(
                            alumnoProvider.evaluaciones[index].competencia ??
                                'Nombre no encontrado'),
                        subtitle: Text(alumnoProvider.evaluaciones[index].fecha!),
                        children: alumnoProvider.evaluaciones[index].noasiste
                            ? [const Text('El alumno no asistió a la sesión')]
                            : [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 0.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.info_outline,
                                                    size: 20),
                                                tooltip:
                                                    '¿Qué significa la puntuación?',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      content:
                                                          const IntrinsicHeight(
                                                        child: StarstairWidget([
                                                          'Está empezando a dar sus primeros pasos para participar con mayor seguridad.',
                                                          'Se anima en algunos momentos, aunque aún necesita impulso para mantener la participación.',
                                                          'Mantiene una disposición adecuada y participa de manera regular en las actividades.',
                                                          'Su actitud es positiva y entusiasta, participa con ganas en las propuestas.',
                                                          'Su disposición es excelente, siempre motivado/a y con ganas de aprender.'
                                                        ]),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              'Cerrar'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text('Actitud'),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: StarRating(
                                                      rating: alumnoProvider
                                                          .evaluaciones[index]
                                                          .comportamiento),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.info_outline,
                                                    size: 20),
                                                tooltip:
                                                    '¿Qué significa la puntuación?',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      content:
                                                          const IntrinsicHeight(
                                                        child: StarstairWidget([
                                                          'Se encuentra en fase inicial, necesita acompañamiento para descubrir su interés.',
                                                          'Logra pequeños avances cuando se le guía, demostrando que está en el camino del crecimiento.',
                                                          'Muestra interés moderado y consigue un progreso estable.',
                                                          'Se esfuerza de manera constante, alcanzando avances notables.',
                                                          'Supera las expectativas, aplica lo aprendido con creatividad y eficacia.'
                                                        ]),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              'Cerrar'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text('Aprendizaje'),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: StarRating(
                                                      rating: alumnoProvider
                                                          .evaluaciones[index]
                                                          .nota),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.info_outline,
                                                    size: 20),
                                                tooltip:
                                                    '¿Qué significa la puntuación?',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      content:
                                                          const IntrinsicHeight(
                                                        child: StarstairWidget([
                                                          'Comienza su camino en la integración al grupo, poco a poco irá encontrando su lugar.',
                                                          'Va dando pasos hacia la colaboración con el grupo, aunque todavía requiere apoyo.',
                                                          'Se integra de manera positiva, aportando al grupo en dinámicas básicas.',
                                                          'Se adapta con facilidad, colabora y ayuda a crear un ambiente de compañerismo.',
                                                          'Es un referente positivo, inspira al grupo y fomenta la colaboración y el buen clima.'
                                                        ]),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              'Cerrar'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text(
                                                  'Adaptación al grupo-clase'),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: StarRating(
                                                      rating: alumnoProvider
                                                          .evaluaciones[index]
                                                          .adaptacion),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          const Text(
                                            'Comentario del profesor:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            alumnoProvider.evaluaciones[index]
                                                        .observaciones ==
                                                    null
                                                ? 'Sin comentarios'
                                                : alumnoProvider
                                                    .evaluaciones[index]
                                                    .observaciones!,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ]),
                                  ),
                                )
                              ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
