import 'package:begabung_app/domain/entities/entities.dart';

class Grupo {
  int? idgrupo;
  String? nombre;
  List<Alumno> alumnos = [];
  Competencia? competencia;

  Grupo();

  Grupo.fromJson(Map<String, dynamic> json) {
    idgrupo = int.parse(json['idgrupo']);
    nombre = json['nombre'];
    competencia = Competencia.fromJson(json['competencia']);
    if (json['alumnos'] != null) {
      alumnos =
          json['alumnos'].map<Alumno>((row) => Alumno.fromJson(row)).toList();
    }
  }
}
