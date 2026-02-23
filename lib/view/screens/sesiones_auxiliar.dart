import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/auxiliar_provider.dart';
import 'package:begabung_app/view/widgets/calendar_auxiliar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SesionesAuxiliarScreen extends StatelessWidget {
  const SesionesAuxiliarScreen({super.key});

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

        sesion.fecha = '$anio-$mesConCeros-$diaConCeros';
        sesionesCal.add(sesion);
      }
    }
    return sesionesCal;
  }

  @override
  Widget build(BuildContext context) {
    final auxiliarProvider = context.watch<AuxiliarProvider>();

    if (auxiliarProvider.sesiones.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Sesion> sesiones = _sesionesCal(auxiliarProvider.sesiones);

    return Stack(children: [
      Column(
        children: [
          const SizedBox(height: 10),
          const Center(
              child: Text('Sesiones', style: TextStyle(fontSize: 24))),
          const SizedBox(height: 10),
          Expanded(
            child: CalendarAuxiliarWidget(sesiones),
          ),
        ],
      ),
    ]);
  }
}
