import 'package:begabung_app/domain/entities/evaluacion.dart';
import 'package:begabung_app/view/widgets/starRating_widget.dart';
import 'package:flutter/material.dart';

class EvaluacionScreen extends StatelessWidget {
  Evaluacion evaluacion = Evaluacion();
  EvaluacionScreen({super.key, required this.evaluacion});
  static const String route = 'evaluacion_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Text('Competencia: ${evaluacion.competencia}'),
          Text('Fecha: ${evaluacion.fecha!}'),
          const Text('Actitud'),
          StarRating(rating: evaluacion.comportamiento),
          const Text('Aprendizaje'),
          StarRating(rating: evaluacion.nota),
          const Text('Adaptación al grupo-clase'),
          StarRating(rating: evaluacion.adaptacion),
          const Text('Comentario del profesor'),
          Text(evaluacion.observaciones ?? 'Sin comentarios'),
        ],
      ),
    );
  }
}
