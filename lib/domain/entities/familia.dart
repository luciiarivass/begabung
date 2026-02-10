import 'dart:convert';

import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:http/http.dart' as http;

class Familiaalumno {
  int? idfamiliaalumno;
  String? nombre;

  static Future<List> getAlumnos(int idfamiliaalumno, String apikey) async {
    var url = Uri.parse(
        '${Api.base}/api/3/alumnos?filter[idfamiliaalumno]=$idfamiliaalumno&filter[activo]=1');
    var response = await http.get(url, headers: {'Token': apikey});
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      List<Alumno> alumnos =
          registros.map<Alumno>((row) => Alumno.fromJsonFS(row)).toList();
      return alumnos;
    } else {
      throw 'No se han encontrado alumnos';
    }
  }
}
