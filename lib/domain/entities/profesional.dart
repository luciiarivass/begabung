import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profesional {
  int? idprofesional;
  String? nombre;
  String? bio;
  String? foto;

  Profesional({this.idprofesional, this.nombre});

  Profesional.fromJson(Map<String, dynamic> json) {
    idprofesional = json['idprofesional'];
    nombre = json['nombre'];
  }

  Future<Profesional> getProfesional(Login login) async {
    var url = Uri.parse(
        '${Api.base}/api/3/profesionales?filter[idprofesional]=${login.idprofesional}');
    var response = await http.get(url, headers: {'Token': login.apikey!});
    if (response.statusCode == 200) {
      final registro = json.decode(response.body);
      Profesional profesional = Profesional.fromJson(registro.first);
      return profesional;
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }
}
