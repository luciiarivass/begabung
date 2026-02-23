import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  List<Sesion> sesiones = [];
  CalendarWidget(this.sesiones);
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
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
    // Limpia el estado del calendario al destruir el widget
    _sesionesPorDia.clear(); // Limpiar el mapa de sesiones
    _selectedDay = null; // Reiniciar la fecha seleccionada
    _focusedDay = DateTime.now(); // Reiniciar la fecha enfocada si es necesario

    // Llamar siempre a super.dispose()
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

  @override
  Widget build(BuildContext context) {
    final profesionalProvider = context.watch<ProfesionalProvider>();
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
                color: Colors.transparent, // Color de fondo del calendario
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blue, // Color de los marcadores
                shape: BoxShape.circle, // Forma del marcador
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
                _actualizarSesionesDelDia(selectedDay);
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _sesionesPorDia[DateTime(day.year, day.month, day.day)] ??
                  [];
            },
            //onDaySelected: _onDaySelected,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _sesionesDelDia.isEmpty
                ? const Center(child: Text('No hay sesiones para este día'))
                : ListView.builder(
                    itemCount: _sesionesDelDia.length,
                    itemBuilder: (context, index) {
                      List<String> palabras = [];
                      if (_sesionesDelDia[index].grupo != null) {
                        palabras = _sesionesDelDia[index].grupo!.split(' ');
                      }
                      return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _sesionesDelDia[index].profesional.nombre == null
                                  ? ListTile(
                                      title: Text(
                                          _sesionesDelDia[index].competencia ?? ''),
                                      subtitle: _sesionesDelDia[index]
                                                  .profesional
                                                  .nombre ==
                                              null
                                          ? (palabras.isNotEmpty &&
                                                  palabras.length >= 3)
                                              ? (palabras.length == 3
                                                  ? Text(
                                                      '${palabras[1]} - ${palabras[0]} ${palabras[2]} - ${_sesionesDelDia[index].hora}')
                                                  : Text(
                                                      '${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]} - ${_sesionesDelDia[index].hora}'))
                                              : Text(
                                                  '${_sesionesDelDia[index].hora}')
                                          : _sesionesDelDia[index].grupo != null &&
                                                  palabras.isNotEmpty &&
                                                  palabras.length >= 3
                                              ? palabras.length == 3
                                                  ? Text(
                                                      '${_sesionesDelDia[index].profesional.nombre!} - ${palabras[1]} - ${palabras[0]} ${palabras[2]} - ${_sesionesDelDia[index].hora}')
                                                  : Text(
                                                      '${_sesionesDelDia[index].profesional.nombre!} - ${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]} - ${_sesionesDelDia[index].hora}')
                                              : Text(
                                                  '${_sesionesDelDia[index].profesional.nombre!} - ${_sesionesDelDia[index].hora}'),
                                      onTap: loading
                                          ? null
                                          : () async {
                                              setState(() => loading = true);
                                              await context
                                                  .read<ProfesionalProvider>()
                                                  .getEvaluaciones();
                                              setState(() => loading = false);

                                              final grupo = profesionalProvider
                                                  .grupos
                                                  .firstWhere(
                                                (grupo) =>
                                                    grupo.idgrupo ==
                                                    _sesionesDelDia[index].idgrupo,
                                              );

                                              final sesion = _sesionesDelDia[index];

                                              context.push('/grupo', extra: {
                                                'grupo': grupo,
                                                'sesion': sesion,
                                              });
                                            },
                                    )
                                  : ExpansionTile(
                                      title: Text(
                                          _sesionesDelDia[index].competencia ?? ''),
                                      subtitle: _sesionesDelDia[index]
                                                  .profesional
                                                  .nombre ==
                                              null
                                          ? (palabras.isNotEmpty &&
                                                  palabras.length >= 3)
                                              ? (palabras.length == 3
                                                  ? Text(
                                                      '${palabras[1]} - ${palabras[0]} ${palabras[2]} - ${_sesionesDelDia[index].hora}')
                                                  : Text(
                                                      '${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]} - ${_sesionesDelDia[index].hora}'))
                                              : Text(
                                                  '${_sesionesDelDia[index].hora}')
                                          : _sesionesDelDia[index].grupo != null &&
                                                  palabras.isNotEmpty &&
                                                  palabras.length >= 3
                                              ? palabras.length == 3
                                                  ? Text(
                                                      '${_sesionesDelDia[index].profesional.nombre!} - ${palabras[1]} - ${palabras[0]} ${palabras[2]} - ${_sesionesDelDia[index].hora}')
                                                  : Text(
                                                      '${_sesionesDelDia[index].profesional.nombre!} - ${palabras[1]} - ${palabras[0]} ${palabras[2]} ${palabras[3]} - ${_sesionesDelDia[index].hora}')
                                              : Text(
                                                  '${_sesionesDelDia[index].profesional.nombre!} - ${_sesionesDelDia[index].hora}'),
                                      children: [
                                        _sesionesDelDia[index].objetivos != ''
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  _sesionesDelDia[index].objetivos,
                                                ),
                                              )
                                            : const Text(
                                                "No hay contenidos definidos para esta sesión"),
                                      ],
                                    ),

                            ],
                          ));

                    },
                  ),
          ),
        ],
      ),
    );
  }
}
