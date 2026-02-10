// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:intl/intl.dart';

class Notificacion {
  int? idnotificacion;
  String? fecha;
  String? titulo;
  String? texto;

  Notificacion(
    this.idnotificacion,
    this.fecha,
    this.titulo,
    this.texto,
  );

  Notificacion.fromJson(Map<String, dynamic> json) {
    idnotificacion = int.parse(json['idnotificacion']);
    List<String> partes = json['fecha'].split(' ')[0].split('-');
    fecha = DateFormat('dd-MM-yyyy').format(DateTime(
      int.parse(partes[0]),
      int.parse(partes[1]),
      int.parse(partes[2]),
    ));
    titulo = json['titulo'];
    texto = json['texto'];
  }
}
