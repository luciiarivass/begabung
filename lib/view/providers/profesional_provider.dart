import 'dart:convert';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfesionalProvider extends ChangeNotifier {
  Profesional? profesional;
  List<Sesion> sesiones = [];
  List<Grupo> grupos = [];
  List<Evaluacion> evaluaciones = [];

  get profesionalProvider => null;

  Future<void> getInfo(int idprofesional) async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');
    await getProfesionalInfo(idprofesional, apikey);
    await getProfesionalSesiones(apikey);
    notifyListeners();
  }

  Future<void> getEvaluaciones() async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');
    await getProfesionalEvaluaciones(apikey);
    //await completarEvaluaciones(apikey);
    notifyListeners();
  }

  void clearInfo() {
    profesional = null;
    sesiones = [];
    evaluaciones = [];
    notifyListeners();
  }

  Future<void> getProfesionalInfo(int idprofesional, String? apikey) async {
    var url = Uri.parse('${Api.base}/api/3/profesionales/$idprofesional');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registro = json.decode(response.body);
      profesional = Profesional.fromJson(registro);
    } else {
      throw 'No se pudo cargar la información del profesional.';
    }
  }


  Future<void> getProfesionalSesiones(String? apikey) async {
    var url = Uri.parse(
        '${Api.base}/api/3/sesionesporid?idprofesional=${profesional?.idprofesional}');
    var responseSesiones = await http.get(url, headers: {'Token': apikey!});
    if (responseSesiones.statusCode == 200) {
      final registros = json.decode(responseSesiones.body);
      sesiones = registros['sesiones']
          .map<Sesion>((row) => Sesion.fromJson(row))
          .toList();
      grupos =
          registros['grupos'].map<Grupo>((row) => Grupo.fromJson(row)).toList();
    } else {
      throw 'No se pudieron cargar las sesiones.';
    }
  }

  getProfesionalEvaluaciones(String? apikey) async {
    var url = Uri.parse(
        '${Api.base}/api/3/evaluacionesporid?idprofesional=${profesional?.idprofesional}');
    var response = await http.get(url, headers: {'Token': apikey!});
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      evaluaciones =
          registros.map<Evaluacion>((row) => Evaluacion.fromJson(row)).toList();
    } else {
      throw 'No se pudieron cargar las evaluaciones.';
    }
  }

  Future<void> guardarEvaluacion(Evaluacion evaluacion) async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";
    var url = Uri.parse('${Api.base}/api/3/evaluaciones');
    var response = await http.post(url, headers: {
      'Token': apikey!
    }, body: {
      'idsesion': evaluacion.idsesion.toString(),
      'idprofesional': evaluacion.idprofesional.toString(),
      'idinteligencia': evaluacion.idcompetencia.toString(),
      'idalumno': evaluacion.idalumno.toString(),
      'fecha': formattedDate,
      'observaciones': evaluacion.observaciones ?? 'Sin comentarios',
      'adaptacion': evaluacion.adaptacion.toString(),
      'comportamiento': evaluacion.comportamiento.toString(),
      'nota': evaluacion.nota.toString(),
      'idcurso': '4',
      'noasiste': evaluacion.noasiste ? '1' : '0',
    });

    if (response.statusCode != 200) {
      throw 'No se pudo guardar la evaluación. Inténtalo de nuevo.';
    }

    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      evaluacion.idevaluacion = int.parse(jsonResponse['data']['idevaluacion']);
      evaluacion.idsesion = int.parse(jsonResponse['data']['idsesion']); 
      evaluacion.fecha = DateFormat('dd-MM-yyyy').format(now);
      evaluaciones.insert(0, evaluacion);
      notifyListeners();
    } catch (e) {
      print(e);
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }
}
