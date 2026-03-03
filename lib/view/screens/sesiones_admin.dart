import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/admin_provider.dart';
import 'package:begabung_app/view/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SesionesAdminScreen extends StatelessWidget {
  const SesionesAdminScreen({super.key});
  List<Sesion> _sesionesCal(List<Sesion> sesiones) {
    List<Sesion> sesionesCal = [];
    for (Sesion sesion in sesiones) {
      if (sesion.fecha != null) {
        List<String> partes = sesion.fecha!.split('-');
        int dia = int.parse(partes[0]);
        int mes = int.parse(partes[1]);
        int anio = int.parse(partes[2]);

        String diaConCeros = dia.toString().padLeft(2, '0');
        String mesConCeros = mes.toString().padLeft(2, '0');

// Asignar la fecha nuevamente con los ceros a la izquierda
        sesion.fecha = '$anio-$mesConCeros-$diaConCeros';
        sesionesCal.add(sesion);
      }
    }
    return sesionesCal;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    if (adminProvider.sesiones.isEmpty) {
      return const Center(
          child:
              CircularProgressIndicator()); // Mostrar loading si no hay sesiones
    }
    List<Sesion> sesiones = _sesionesCal(adminProvider.sesiones);
    return Stack(children: [
      Column(
        children: [
          const SizedBox(height: 10),
          const Center(child: Text('Sesiones', style: TextStyle(fontSize: 24))),
          const SizedBox(height: 10),
          Expanded(
            child: CalendarWidget(
              sesiones,
            ),
          ),
        ],
      ),
    ]);
  }
}
