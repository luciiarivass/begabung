import 'package:intl/intl.dart';

class Feedback {
  int? idfeedback;
  int? idalumno;
  int? idsesion;
  int? idprofesional;
  int? idgrupo;
  String? fecha;
  int? notaSesion;
  int? notaProfesional;
  String? observaciones;

  Feedback();

  Feedback.fromJson(Map<String, dynamic> json) {
    idfeedback = json['idfeedback'];
    idalumno = json['idalumno'];
    idsesion = json['idsesion'];
    idprofesional = json['idprofesional'];
    idgrupo = json['idgrupo'];
    notaSesion = json['nota_sesion'];
    notaProfesional = json['nota_profesional'];
    observaciones = json['observaciones'];
    if (json['fecha'] != null) {
      List<String> partes = json['fecha'].split(' ')[0].split('-');
      fecha = DateFormat('dd-MM-yyyy').format(DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      ));
    }
  }
}
