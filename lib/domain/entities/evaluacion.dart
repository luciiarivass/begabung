class Evaluacion {
  int? idevaluacion;
  int? idalumno;
  int? idcompetencia;
  int? idprofesional;
  int adaptacion = 0;
  int comportamiento = 0;
  int nota = 0;
  String? fecha;
  String? competencia;
  String? observaciones;
  bool noasiste = false;
  int? idsesion;

  Evaluacion();

  Evaluacion.fromJson(Map<String, dynamic> json) {
    idevaluacion = json['idevaluacion'];
    idsesion = json['idsesion'];
    idalumno = json['idalumno'];
    idprofesional = json['idprofesional'];
    idcompetencia = json['idinteligencia'];
    adaptacion = json['adaptacion'];
    comportamiento = json['comportamiento'];
    nota = json['nota'];
    fecha = json['fecha'];
    observaciones = json['observaciones'];
    noasiste = json['noasiste'];
    competencia = json['nombreCompetencia'];
  }
}
