import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/evaluacion.dart';
import 'package:begabung_app/view/widgets/starRatingChange_widget.dart';
import 'package:begabung_app/view/widgets/starRating_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EvaluacionWidget extends StatefulWidget {
  final Evaluacion evaluacion;
  final Alumno alumno;

  EvaluacionWidget({Key? key, required this.evaluacion, required this.alumno})
      : super(key: key);

  @override
  _EvaluacionWidgetState createState() => _EvaluacionWidgetState();
}

class _EvaluacionWidgetState extends State<EvaluacionWidget> {
  late Evaluacion _evaluacion;
  late Alumno alumno;

  @override
  void initState() {
    super.initState();
    _evaluacion = widget.evaluacion;
    alumno = widget.alumno;
  }

  @override
Widget build(BuildContext context) {
  final bgColor = _evaluacion.noasiste ? Colors.amber : Colors.green[100];

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12), // ✅ bordes redondos
      border: Border.all(color: Colors.black12),
    ),
    child: _evaluacion.noasiste
        ? const Text('El alumno no asistió a la sesión')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FECHA ARRIBA
              Text(
                _evaluacion.fecha?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Actitud'),
                      Text('Aprendizaje'),
                      Text('Adaptación al grupo-clase'),
                    ],
                  ),
                  Column(
                    children: [
                      StarRating(rating: _evaluacion.comportamiento),
                      StarRating(rating: _evaluacion.nota),
                      StarRating(rating: _evaluacion.adaptacion),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Comentario del profesor:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _evaluacion.observaciones ?? 'Sin comentarios',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
  );
}
}


class NewEvaluacionWidget extends StatefulWidget {
  final Evaluacion evaluacion;
  final Alumno alumno;
  final int idsesion;

  final Future<void> Function(Evaluacion, int, [bool]) onSave;


  const NewEvaluacionWidget({
    Key? key,
    required this.evaluacion,
    required this.onSave,
    required this.alumno,
    required this.idsesion, 
  }) : super(key: key);

  @override
  _NewEvaluacionWidgetState createState() => _NewEvaluacionWidgetState();
}

class _NewEvaluacionWidgetState extends State<NewEvaluacionWidget> {
  late Evaluacion _evaluacion;
  late Alumno alumno;
  ImageProvider? _imageProvider;
  bool _isSaved = false;
  late TextEditingController _controller;

  final Map<String, List<String>> bloques = {
    "Actitud": [
      "Afronta las actividades con curiosidad y entusiasmo.",
      "Su energía positiva contagia al grupo y dinamiza la sesión.",
      "Se muestra dispuesto/a a aprender y a dar lo mejor de sí mismo/a.",
      "Aporta creatividad y originalidad en cada propuesta.",
      "Destaca por su constancia y su afán de superación.",
      "Muestra una actitud abierta y receptiva ante nuevos retos.",
      "Necesita un pequeño empujón para empezar, pero cuando lo hace, despliega todo su potencial.",
      "Le cuesta mantener la atención en algunos momentos, aunque logra reconducirse con rapidez.",
      "Puede mostrarse reservado/a al inicio, pero cuando se implica, su creatividad brilla.",
      "Todavía está aprendiendo a gestionar la constancia, pero su entusiasmo lo compensa con creces.",
      "Enfrenta con valentía las actividades que le resultan más difíciles, mostrando progreso constante."
    ],
    "Aprendizaje": [
      "Integra los aprendizajes con rapidez y los aplica de forma creativa.",
      "Sus reflexiones enriquecen la dinámica y generan nuevas ideas.",
      "Aprende con facilidad y muestra interés por profundizar más allá de lo básico.",
      "Hace conexiones originales entre los contenidos y la práctica.",
      "Avanza con seguridad, aportando soluciones innovadoras.",
      "Sorprende por su capacidad de comprender y transformar lo aprendido en propuestas nuevas.",
      "Algunos contenidos requieren más tiempo de asimilación, pero su esfuerzo marca la diferencia.",
      "Todavía consolida ciertos aprendizajes, aunque cada sesión avanza con paso firme.",
      "Puede necesitar apoyo extra en algunos temas, pero siempre encuentra la manera de salir adelante.",
      "Se enfrenta a los retos con paciencia, aprendiendo de cada intento.",
      "Aunque a veces duda, logra transformar esa incertidumbre en oportunidades de aprendizaje.",
    ],
    "Adaptación": [
      "Se relaciona con sus compañeros de forma natural y respetuosa.",
      "Contribuye a un ambiente de cooperación y confianza.",
      "Favorece la participación de todos con su disposición y empatía.",
      "Se adapta con facilidad a diferentes dinámicas de grupo.",
      "Su presencia aporta cohesión y armonía al equipo.",
      "Disfruta trabajando en grupo y enriquece las actividades con sus aportaciones.",
      "Prefiere trabajar de manera individual, aunque cuando colabora aporta ideas muy valiosas.",
      "Se está abriendo poco a poco al grupo, y cada avance suma a la dinámica colectiva.",
      "A veces le cuesta ceder, pero aprende a escuchar y a respetar los puntos de vista de los demás.",
      "Necesita más confianza para expresarse, aunque cada participación suya enriquece mucho al grupo.",
      "Tiende a elegir a los mismos compañeros, pero cuando se abre al resto se generan resultados muy positivos.",
    ]
  };

  void _addFrase(String frase) {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text += "\n$frase";
      } else {
        _controller.text = frase;
      }
      _evaluacion.observaciones = _controller.text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _evaluacion = widget.evaluacion;
    alumno = widget.alumno;
    _controller = TextEditingController(
      text: _evaluacion.observaciones,
    );
    _loadImage(alumno.idalumno.toString());
  }

  Future<void> _saveEvaluacion() async {
  try {
    await widget.onSave(_evaluacion, widget.idsesion);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Evaluación guardada con éxito!"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al guardar la evaluación: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Future<void> _saveNoAsiste() async {
  try {
    await widget.onSave(_evaluacion, widget.idsesion, true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Falta de asistencia guardada con éxito!"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al guardar la falta de asistencia: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  _loadImage(String baseUrl) async {
    final formats = ['jpg', 'jpeg', 'png'];
    for (var format in formats) {
      final url = '${Api.base}/MyFiles/Public/$baseUrl.$format';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _imageProvider = NetworkImage(url);
          });
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        _imageProvider = const AssetImage('assets/icon/logoios.jpg');
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420;

        Widget ratingsColumn() {
          return Column(
            children: [
              const Text('Actitud'),
              FittedBox(
                child: StarRatingChange(
                  rating: _evaluacion.comportamiento,
                  onRatingChanged: (rating) {
                    setState(() => _evaluacion.comportamiento = rating);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text('Aprendizaje'),
              FittedBox(
                child: StarRatingChange(
                  rating: _evaluacion.nota,
                  onRatingChanged: (rating) {
                    setState(() => _evaluacion.nota = rating);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text('Adaptación al grupo-clase'),
              FittedBox(
                child: StarRatingChange(
                  rating: _evaluacion.adaptacion,
                  onRatingChanged: (rating) {
                    setState(() => _evaluacion.adaptacion = rating);
                  },
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Nueva evaluación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Parte superior responsive
            if (narrow) ...[
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _imageProvider,
                ),
              ),
              const SizedBox(height: 12),
              Center(child: ratingsColumn()),
            ] else ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _imageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(child: ratingsColumn()),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),
            const Text(
              'Comentario del profesor:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<String>(
                color: const Color.fromARGB(255, 250, 250, 250),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_comment_outlined),
                      SizedBox(width: 8),
                      Text("Añadir comentarios propuestos"),
                    ],
                  ),
                ),
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> items = [];

                  bloques.forEach((titulo, frases) {
                    items.add(PopupMenuItem<String>(
                      enabled: false,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ));

                    for (var frase in frases) {
                      items.add(PopupMenuItem<String>(
                        value: frase,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(frase, softWrap: true)),
                          ],
                        ),
                      ));
                    }

                    items.add(const PopupMenuDivider(thickness: 2, height: 50));
                  });

                  if (items.isNotEmpty) items.removeLast();
                  return items;
                },
                onSelected: (fraseSeleccionada) => _addFrase(fraseSeleccionada),
              ),
            ),

            TextFormField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe un comentario',
              ),
              onChanged: (value) {
                setState(() => _evaluacion.observaciones = value);
              },
            ),

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveEvaluacion,
                  child: const Text('Guardar evaluación'),
                ),
                ElevatedButton(
                  onPressed: _saveNoAsiste,
                  child: const Text('No asiste'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
}
