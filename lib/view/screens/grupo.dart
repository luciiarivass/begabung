import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/domain/entities/evaluacion.dart';
import 'package:begabung_app/domain/entities/grupo.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:begabung_app/view/widgets/evaluacion_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GrupoScreen extends StatefulWidget {
  static const String route = 'grupo_screen';
  final Grupo grupo;
  final int idsesion;

  const GrupoScreen({
    super.key,
    required this.grupo,
    required this.idsesion,
  });

  @override
  State<GrupoScreen> createState() => _GrupoScreenState();
}

class _GrupoScreenState extends State<GrupoScreen> {
  bool saving = false; // opcional, por si quieres bloquear mientras guarda

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupo;
    final idsesion = widget.idsesion;

    final profesionalProvider = context.watch<ProfesionalProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Evaluaciones'),
            const SizedBox(height: 5),
            Text(
              grupo.nombre ?? '',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: grupo.alumnos.isEmpty
          ? Column(
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
                const Text(
                  'Parece que no hay nada por aquí.',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : ListView.builder(
              itemCount: grupo.alumnos.length,
              itemBuilder: (context, index) {
                final alumno = grupo.alumnos[index];

                final evaluacionesDeEstaSesion = profesionalProvider
                    .evaluaciones
                    .where((e) =>
                        e.idalumno == alumno.idalumno &&
                        e.idsesion == idsesion &&
                        e.idcompetencia == grupo.competencia?.idcompetencia &&
                        e.idprofesional ==
                            profesionalProvider.profesional?.idprofesional)
                    .toList();

                final Evaluacion? evaluacionExistente =
                    evaluacionesDeEstaSesion.isNotEmpty
                        ? evaluacionesDeEstaSesion.first
                        : null;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              alumno.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (evaluacionExistente != null)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      children: [
                        if (evaluacionExistente != null)
                          EvaluacionWidget(
                            key: ValueKey(
                                'evaluacion_${idsesion}_${alumno.idalumno}'),
                            evaluacion: evaluacionExistente,
                            alumno: alumno,
                          )
                        else
                          NewEvaluacionWidget(
                            key: ValueKey(
                                'new_evaluacion_${idsesion}_${alumno.idalumno}'),
                            evaluacion: Evaluacion(),
                            idsesion: idsesion,
                            alumno: alumno,
                            onSave: (evaluacion, idsesion,
                                [bool noAsiste = false]) async {
                              evaluacion.idalumno = alumno.idalumno;
                              evaluacion.idcompetencia =
                                  grupo.competencia?.idcompetencia;
                              evaluacion.noasiste = noAsiste;
                              evaluacion.idprofesional = profesionalProvider
                                  .profesional?.idprofesional;
                              evaluacion.idsesion = idsesion;

                              await profesionalProvider.guardarEvaluacion(
                                  evaluacion);

                              if (mounted) setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
