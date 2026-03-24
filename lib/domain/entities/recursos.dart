import 'dart:io';

class Recurso {
  int? idrecurso;
  int? idprofesional;
  int? idgrupo;
  int? idgrupo2;
  int? idgrupo3;
  int? idgrupo4;
  int? idsede;
  int? idfamiliaalumno;
  int? idinteligencia;
  bool? todos;
  String? titulo;
  String? descripcion;
  String? url;
  String? fichero;
  File? ficheroFile;
  bool? publicado;
  String? fechaPublicacion;
  String? competencia;

  Recurso();

  static int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

Recurso.fromJson(Map<String, dynamic> json) {
  idrecurso = _parseInt(json['idrecurso']);
  idprofesional = _parseInt(json['idprofesional']);
  idgrupo = _parseInt(json['idgrupo']);
  idgrupo2 = _parseInt(json['idgrupo2']);
  idgrupo3 = _parseInt(json['idgrupo3']);
  idgrupo4 = _parseInt(json['idgrupo4']);
  idsede = _parseInt(json['idsede']);
  idfamiliaalumno = _parseInt(json['idfamiliaalumno']);
  idinteligencia = _parseInt(json['idinteligencia']);
  titulo = json['titulo']?.toString();
  descripcion = json['descripcion']?.toString();
  url = json['url']?.toString();
  fichero = json['fichero']?.toString();
  competencia = json['nombreCompetencia'];
  todos = json['todos'] == 1 || json['todos'] == true || json['todos']?.toString() == '1';
  publicado = json['publicado'] == 1 || json['publicado'] == true || json['publicado']?.toString() == '1';

  fechaPublicacion = json['fecha_publicacion'];
}
}
