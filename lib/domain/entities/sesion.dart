import 'package:begabung_app/domain/entities/profesional.dart';

class Sesion {
  int? idsesion;
  int? idgrupo;
  int? idprofesional;
  int? idcompetencia;
  String? fecha;
  Profesional profesional = Profesional();
  String? competencia;
  String? grupo;
  String? hora;
  String objetivos = '';

  Sesion(
      {this.idsesion,
      this.idgrupo,
      this.idprofesional,
      this.idcompetencia,
      this.fecha});

  Sesion.fromJson(Map<String, dynamic> json) {
    idsesion = json['idsesion'];
    idgrupo = json['idgrupo'];
    idprofesional = json['idprofesional'];
    idcompetencia = json['idinteligencia'];
    if (json['objetivos'] != null) {
      objetivos = json['objetivos'];
    }
    fecha = json['fecha'];

    // La API a veces devuelve la cadena "null" en lugar de null real
    // Necesitamos detectar esto y tratarlo como null
    var nombreGrupoValue = json['nombreGrupo'];
    if (nombreGrupoValue != null && nombreGrupoValue.toString() != 'null') {
      grupo = nombreGrupoValue.toString().trim();
    }

    var nombreCompetenciaValue = json['nombreCompetencia'];
    if (nombreCompetenciaValue != null &&
        nombreCompetenciaValue.toString() != 'null') {
      competencia = nombreCompetenciaValue.toString().trim();
    }

    hora = json['hora'] == null ? '' : json['hora'].substring(0, 5);
    profesional = Profesional(
        idprofesional: idprofesional, nombre: json['nombreProfesional']);
  }
}
