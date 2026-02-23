import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ValoracionScreen extends StatefulWidget {
  const ValoracionScreen({super.key});

  @override
  State<ValoracionScreen> createState() => _ValoracionScreenState();
}

class _ValoracionScreenState extends State<ValoracionScreen> {
  DateTime _parseDate(String fecha) {
    final p = fecha.split('-');
    if (p[0].length == 4) {
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } else {
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }
  }

  String _fechaLegible(String fecha) {
    final d = _parseDate(fecha);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  List<Sesion> _sesionesConFecha(List<Sesion> sesiones) =>
      sesiones.where((s) => s.fecha != null).toList();

  void _mostrarDialogoValoracion(Sesion sesion) {
    final provider = context.read<AlumnoProvider>();
    final yaEvaluada = provider.sesionesEvaluadas.contains(sesion.idsesion);

    if (yaEvaluada) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sesión ya valorada'),
          content: const Text(
              'Ya has enviado una valoración para esta sesión.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    int estrellasProfe = 5;
    int estrellasActividad = 5;
    final TextEditingController obsController = TextEditingController();
    final fechaLegible = _fechaLegible(sesion.fecha!);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('Sesión del $fechaLegible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Cómo valorarías a tu profe de hoy?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      i < estrellasProfe ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setD(() => estrellasProfe = i + 1),
                  )),
                ),
                const SizedBox(height: 16),
                const Text(
                    '¿Cómo valorarías lo que has hecho en la sesión de hoy?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      i < estrellasActividad ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setD(() => estrellasActividad = i + 1),
                  )),
                ),
                const SizedBox(height: 16),
                const Text('Propón tu siguiente reto Begabung:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: obsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Escribe aquí tu propuesta...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final error = await context.read<AlumnoProvider>().guardarFeedback(
                  idsesion: sesion.idsesion ?? 0,
                  idgrupo: sesion.idgrupo ?? 0,
                  idprofesional: sesion.idprofesional ?? 0,
                  notaProfe: estrellasProfe,
                  notaSesion: estrellasActividad,
                  observaciones: obsController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error == null
                        ? '✅ Valoración guardada correctamente'
                        : '⚠️ $error'),
                    duration: const Duration(seconds: 4),
                  ));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCalendario() {
    final sesiones = _sesionesConFecha(context.read<AlumnoProvider>().sesiones);
    final sesionesEvaluadas = context.read<AlumnoProvider>().sesionesEvaluadas;

    final Map<DateTime, List<Sesion>> sesionesPorDia = {};
    for (final s in sesiones) {
      final fecha = _parseDate(s.fecha!);
      final key = DateTime(fecha.year, fecha.month, fecha.day);
      sesionesPorDia.putIfAbsent(key, () => []).add(s);
    }

    DateTime focusedDay = DateTime.now();
    DateTime? selectedDay = focusedDay;
    List<Sesion> sesionesDelDia = sesionesPorDia[
            DateTime(focusedDay.year, focusedDay.month, focusedDay.day)] ?? [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Selecciona una sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              TableCalendar(
                locale: 'es_ES',
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2040, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                ),
                eventLoader: (day) =>
                    sesionesPorDia[DateTime(day.year, day.month, day.day)] ?? [],
                onDaySelected: (selDay, focDay) {
                  setD(() {
                    selectedDay = selDay;
                    focusedDay = focDay;
                    sesionesDelDia = sesionesPorDia[
                            DateTime(selDay.year, selDay.month, selDay.day)] ?? [];
                  });
                },
                onPageChanged: (focDay) => focusedDay = focDay,
              ),
              const Divider(),
              SizedBox(
                height: 180,
                child: sesionesDelDia.isEmpty
                    ? const Center(child: Text('No hay sesiones para este día'))
                    : ListView.builder(
                        itemCount: sesionesDelDia.length,
                        itemBuilder: (_, i) {
                          final s = sesionesDelDia[i];
                          final evaluada = sesionesEvaluadas.contains(s.idsesion);
                          return ListTile(
                            leading: Icon(
                              evaluada ? Icons.check_circle : Icons.event,
                              color: evaluada ? Colors.green : Colors.blue,
                            ),
                            title: Text(s.competencia ?? s.grupo ?? ''),
                            subtitle: Text(
                                '${s.profesional.nombre ?? ''} · ${s.hora ?? ''}'),
                            trailing: evaluada
                                ? const Chip(
                                    label: Text('Ya valorada',
                                        style: TextStyle(fontSize: 11)),
                                    backgroundColor: Color(0xFFE8F5E9),
                                    padding: EdgeInsets.zero,
                                  )
                                : const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              _mostrarDialogoValoracion(s);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estrellitas(int? n) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) => Icon(
          i < (n ?? 0) ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        )),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlumnoProvider>();
    final feedbacks = provider.feedbacks;

    return Stack(
      children: [
    
        if (feedbacks.isEmpty)
          Center(
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
                const Text('Danos tu opinión sobre las sesiones',
                    textAlign: TextAlign.center),
                const Text('¡Tu feedback nos ayuda a mejorar!',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        if (feedbacks.isNotEmpty)
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            itemCount: feedbacks.length,
            itemBuilder: (_, index) {
              final f = feedbacks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (f.fecha != null)
                        Text('Sesión del ${f.fecha}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const SizedBox(width: 80,
                            child: Text('Profe:',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        _estrellitas(f.notaProfesional),
                        Text(' (${f.notaProfesional ?? '-'}/5)',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        const SizedBox(width: 80,
                            child: Text('Sesión:',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        _estrellitas(f.notaSesion),
                        Text(' (${f.notaSesion ?? '-'}/5)',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
                      if (f.observaciones != null &&
                          f.observaciones!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Mi reto:',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(f.observaciones!,
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

        // ── Botón + ──────────────────────────────────────────────────────
        Positioned(
          top: 8,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'valoracion_fab',
            onPressed: _mostrarCalendario,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
