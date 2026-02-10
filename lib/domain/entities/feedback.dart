import 'dart:io';

class Feedback {
  int? idalumno;
  int? idfeedback;
  int? idsesion;
  int? idgrupo;
  String? notaSesion;
  String? notaProfesional;
  Feedback();

    Feedback.fromJson(Map<String, dynamic> json) {
    idfeedback = json['idfeedback'];
    idalumno = json['idalumno'];
    idsesion = json['idsesion'];
    idgrupo = json["idgrupo"];
    notaSesion = json['notaSesion'];
    notaProfesional = json['notaProfesional'];
    }
}
