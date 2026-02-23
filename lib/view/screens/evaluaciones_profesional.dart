import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EvaluacionesProfesionalScreen extends StatefulWidget {
  const EvaluacionesProfesionalScreen({super.key});

  @override
  State<EvaluacionesProfesionalScreen> createState() =>
      _EvaluacionesProfesionalScreenState();
}

class _EvaluacionesProfesionalScreenState
    extends State<EvaluacionesProfesionalScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final profesionalProvider = context.watch<ProfesionalProvider>();
    return Column(
      children: [
        const Center(
            child: Text('Evaluaciones', style: TextStyle(fontSize: 24))),
        loading ? const LinearProgressIndicator() : Container(),
        Expanded(
          child: profesionalProvider.grupos.isEmpty
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
                      'No constas como profesional en ningúna sesión',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: profesionalProvider.grupos.length,
                  itemBuilder: (context, index) {
                    List<String> palabras =
                        profesionalProvider.grupos[index].nombre!.split(' ');
                    return ListTile(
                      title: palabras.length == 3
                          ? Text(
                              '${palabras[1]} - ${palabras[0]} ${palabras[2]}' ??
                                  'Nombre no encontrado')
                          : Text(
                              '${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]}' ??
                                  'Nombre no encontrado'),
                      subtitle: Text(profesionalProvider
                              .grupos[index].competencia?.nombre ??
                          'Competencia no encontrada'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: loading
                          ? null
                          : () async {
                              setState(() {
                                loading = true;
                              });
                              await context
                                  .read<ProfesionalProvider>()
                                  .getEvaluaciones();

                              setState(() {
                                loading = false;
                              });

                              final grupoSeleccionado =
                                  profesionalProvider.grupos[index];
                              context.push(
                                '/sesiones-grupo',
                                extra: {
                                  'grupo': grupoSeleccionado,
                                },
                              );
                            },
                    );
                  }),
        ),
      ],
    );
  }
}
