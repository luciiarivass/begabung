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
    idalumno = int.parse(json['idalumno']);
    idfamiliaalumno = int.parse(json['idfamiliaalumno']);
    idgrupo = int.parse(json['idgrupo']);
    nombre = json['nombre'];
  }
  Alumno.fromJsonFS(Map<String, dynamic> json) {
    idalumno = json['idalumno'];
    idfamiliaalumno = json['idfamiliaalumno'];
    idgrupo = json['idgrupo'];
    idsede = json['idsede'];
    nombre = json['nombre'];
  }
}
