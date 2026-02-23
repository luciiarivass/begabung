import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/auxiliar_provider.dart';
import 'package:begabung_app/view/screens/sesion_asistencia.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// Versión del CalendarWidget para el rol Auxiliar.
/// Al pulsar una sesión, carga los alumnos del grupo y navega a SesionAsistenciaScreen.
class CalendarAuxiliarWidget extends StatefulWidget {
  List<Sesion> sesiones = [];
  CalendarAuxiliarWidget(this.sesiones);

  @override
  _CalendarAuxiliarWidgetState createState() =>
      _CalendarAuxiliarWidgetState();
}

class _CalendarAuxiliarWidgetState extends State<CalendarAuxiliarWidget> {
  late Map<DateTime, List<Sesion>> _sesionesPorDia;
  List<Sesion> _sesionesDelDia = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<Sesion> sesiones;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    sesiones = widget.sesiones;
    _selectedDay = _focusedDay;
    _agruparSesionesPorFecha();
    _actualizarSesionesDelDia(_selectedDay!);
  }

  @override
  void dispose() {
    _sesionesPorDia.clear();
    _selectedDay = null;
    _focusedDay = DateTime.now();
    super.dispose();
  }

  void _actualizarSesionesDelDia(DateTime selectedDay) {
    setState(() {
      _sesionesDelDia = _sesionesPorDia[
              DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ??
          [];
    });
  }

  void _agruparSesionesPorFecha() {
    _sesionesPorDia = {};
    for (Sesion sesion in sesiones) {
      final fecha = DateTime.parse(sesion.fecha!);
      final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);

      if (_sesionesPorDia[fechaNormalizada] == null) {
        _sesionesPorDia[fechaNormalizada] = [];
      }
      _sesionesPorDia[fechaNormalizada]!.add(sesion);
    }
  }

  Future<void> _abrirAsistencia(BuildContext context, Sesion sesion) async {
    if (loading) return;
    setState(() => loading = true);

    try {
      final provider = context.read<AuxiliarProvider>();
      final alumnos = await provider.getAlumnosDeGrupo(sesion.idgrupo!);

      if (!context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SesionAsistenciaScreen(
            sesion: sesion,
            alumnos: alumnos,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando alumnos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auxiliarProvider = context.watch<AuxiliarProvider>();
    final sesionesEvaluadas = auxiliarProvider.sesionesEvaluadas;

    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2040, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            calendarStyle: const CalendarStyle(
              defaultDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _actualizarSesionesDelDia(selectedDay);
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _sesionesPorDia[
                      DateTime(day.year, day.month, day.day)] ??
                  [];
            },
          ),
          const SizedBox(height: 8.0),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: _sesionesDelDia.isEmpty
                ? const Center(
                    child: Text('No hay sesiones para este día'))
                : ListView.builder(
                    itemCount: _sesionesDelDia.length,
                    itemBuilder: (context, index) {
                      final sesion = _sesionesDelDia[index];
                      final evaluada = sesion.idsesion != null &&
                          sesionesEvaluadas.contains(sesion.idsesion);

                      List<String> palabras = [];
                      if (sesion.grupo != null) {
                        palabras = sesion.grupo!.split(' ');
                      }

                      String subtituloGrupo = sesion.grupo ?? '';
                      if (palabras.length == 3) {
                        subtituloGrupo =
                            '${palabras[1]} - ${palabras[0]} ${palabras[2]}';
                      } else if (palabras.length >= 4) {
                        subtituloGrupo =
                            '${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]}';
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: evaluada
                              ? Colors.green.shade50
                              : null,
                          border: Border.all(
                            color: evaluada
                                ? Colors.green.shade300
                                : Colors.blueGrey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: Icon(
                            evaluada
                                ? Icons.check_circle
                                : Icons.how_to_reg,
                            color: evaluada ? Colors.green : Colors.blue,
                          ),
                          title: Text(
                            sesion.competencia ?? sesion.grupo ?? 'Sesión',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '$subtituloGrupo - ${sesion.hora ?? ''}',
                          ),
                          trailing: loading
                              ? null
                              : evaluada
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Evaluada',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                          onTap: () => _abrirAsistencia(context, sesion),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
