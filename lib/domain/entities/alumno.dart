import 'dart:io';

class Alumno {
  int? idalumno;
  int? idfamiliaalumno;
  int? idgrupo;
  int? idsede;
  String nombre = '';
  File? imagen;

  Alumno({this.idalumno, this.idfamiliaalumno, this.idgrupo});

  Alumno.fromJson(Map<String, dynamic> json) {
    idalumno = _parseInt(json['idalumno']);
    idfamiliaalumno = _parseInt(json['idfamiliaalumno']);
    idgrupo = _parseInt(json['idgrupo']);
    nombre = json['nombre']?.toString() ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
  Alumno.fromJsonFS(Map<String, dynamic> json) {
    idalumno = json['idalumno'];
    idfamiliaalumno = json['idfamiliaalumno'];
    idgrupo = json['idgrupo'];
    idsede = json['idsede'];
    nombre = json['nombre'];
  }
}
