import 'dart:convert';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AlumnoProvider extends ChangeNotifier {
  Alumno? alumno;
  bool hermanos = false;
  String? grupo;
  String? competencia;
  List<Sesion> sesiones = [];
  List<Evaluacion> evaluaciones = [];
  List<Notificacion> notificaciones = [];

  bool _loading = false;
  int? _loadedAlumnoId; 

  Future<void> getInfo(int idalumno, {bool force = false}) async {
    if (_loading) return;
    if (!force && _loadedAlumnoId == idalumno && alumno != null) return;

    _loading = true;
    try {
      const storage = FlutterSecureStorage();
      final apikey = await storage.read(key: 'apikey');

      await getAlumnoInfo(idalumno, apikey);
      await getAlumnoSesiones(apikey);
      await getAlumnoEvaluaciones(apikey);
      await getAlumnoNotificaciones(apikey);

      _loadedAlumnoId = idalumno;
      notifyListeners();
    } finally {
      _loading = false;
    }
  }

  void clearInfo() {
    alumno = null;
    grupo = null;
    competencia = null;
    sesiones = [];
    evaluaciones = [];
    notificaciones = [];
    _loadedAlumnoId = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> getAlumnoInfo(int idalumno, String? apikey) async {
    final url = Uri.parse('${Api.base}/api/3/alumnos/$idalumno');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registro = json.decode(response.body);
      alumno = Alumno.fromJsonFS(registro);
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoSesiones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/sesionesporid?idalumno=${alumno?.idalumno}');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      grupo = registros[0]['nombreGrupo'];
      sesiones = registros.map<Sesion>((row) => Sesion.fromJson(row)).toList();
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoEvaluaciones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/evaluacionesporid?idalumno=${alumno?.idalumno}');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      evaluaciones =
          registros.map<Evaluacion>((row) => Evaluacion.fromJson(row)).toList();
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoNotificaciones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/notificaciones?idalumno=${alumno?.idalumno}');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      notificaciones = registros
          .map<Notificacion>((row) => Notificacion.fromJson(row))
          .toList();
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }
}
