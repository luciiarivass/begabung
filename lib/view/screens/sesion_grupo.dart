import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';

enum FiltroEstadoSesion { todas, pendientes, evaluadas }

class SesionesGrupoScreen extends StatefulWidget {
  final Grupo grupo;

  const SesionesGrupoScreen({
    super.key,
    required this.grupo,
  });

  @override
  State<SesionesGrupoScreen> createState() => _SesionesGrupoScreenState();
}

class _SesionesGrupoScreenState extends State<SesionesGrupoScreen> {
  FiltroEstadoSesion filtro = FiltroEstadoSesion.todas;

  @override
  Widget build(BuildContext context) {
    final profesionalProvider = context.watch<ProfesionalProvider>();

    /// ✅ Saber si una sesión está evaluada (por idsesion)
    bool sesionEvaluada(int? idsesion) {
      if (idsesion == null) return false;

      return profesionalProvider.evaluaciones.any((e) => e.idsesion == idsesion);
      // Si quieres que NO cuente noasiste:
      // return profesionalProvider.evaluaciones.any((e) => e.idsesion == idsesion && e.noasiste == false);
    }

    /// ✅ Sesiones del grupo + ordenadas reciente -> antigua
    final List<Sesion> sesionesDelGrupoOrdenadas = profesionalProvider.sesiones
        .where((s) => s.idgrupo == widget.grupo.idgrupo)
        .toList()
      ..sort((a, b) => fechaOrdenSesion(b).compareTo(fechaOrdenSesion(a)));

    /// ✅ Aplicar filtro (todas / pendientes / evaluadas)
    final List<Sesion> sesionesFiltradas = sesionesDelGrupoOrdenadas.where((s) {
      final eval = sesionEvaluada(s.idsesion);
      switch (filtro) {
        case FiltroEstadoSesion.todas:
          return true;
        case FiltroEstadoSesion.pendientes:
          return !eval;
        case FiltroEstadoSesion.evaluadas:
          return eval;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grupo.nombre ?? 'Sesiones'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                const Text('Mostrar:'),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<FiltroEstadoSesion>(
                    value: filtro,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: FiltroEstadoSesion.todas,
                        child: Text('Todas'),
                      ),
                      DropdownMenuItem(
                        value: FiltroEstadoSesion.pendientes,
                        child: Text('Pendientes'),
                      ),
                      DropdownMenuItem(
                        value: FiltroEstadoSesion.evaluadas,
                        child: Text('Evaluadas'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => filtro = v);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: sesionesFiltradas.isEmpty
                ? const Center(child: Text('No hay sesiones para este grupo'))
                : ListView.builder(
                    itemCount: sesionesFiltradas.length,
                    itemBuilder: (context, index) {
                      final sesion = sesionesFiltradas[index];
                      final evaluada = sesionEvaluada(sesion.idsesion);

                      return ListTile(
                        title: Text(sesion.competencia ?? 'Sesión'),
                        subtitle: Text(
                          '${formatFechaFlexible(sesion.fecha)} ${formatHoraSoloHHmm(sesion.hora)}'
                              .trim(),
                        ),
                        trailing: evaluada
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.pending_actions, color: Colors.orange),
                        onTap: () {
                          context.push(
                            '/grupo',
                            extra: {
                              'grupo': widget.grupo,
                              'sesion': sesion,
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

DateTime? parseFechaFlexible(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;

  final isoCandidate = s.replaceFirst(' ', 'T');
  try {
    return DateTime.parse(isoCandidate);
  } catch (_) {}
  try {
    return DateFormat('dd-MM-yyyy').parseStrict(s);
  } catch (_) {}

  try {
    return DateFormat('dd/MM/yyyy').parseStrict(s);
  } catch (_) {}

  return null;
}

DateTime fechaOrdenSesion(Sesion sesion) {
  final dt = parseFechaFlexible(sesion.fecha);
  if (dt == null) return DateTime.fromMillisecondsSinceEpoch(0);

  final h = (sesion.hora ?? '').trim();
  if (h.isEmpty) return dt;

  final parts = h.split(':');
  if (parts.length >= 2) {
    final hh = int.tryParse(parts[0]) ?? 0;
    final mm = int.tryParse(parts[1]) ?? 0;
    return DateTime(dt.year, dt.month, dt.day, hh, mm);
  }
  return dt;
}

String formatFechaFlexible(String? fecha) {
  final dt = parseFechaFlexible(fecha);
  if (dt == null) return (fecha ?? '');
  return DateFormat('dd/MM/yyyy').format(dt);
}

String formatHoraSoloHHmm(String? hora) {
  if (hora == null) return '';
  final s = hora.trim();
  if (s.isEmpty) return '';
  final parts = s.split(':');
  if (parts.length >= 2) return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  return s;
}
