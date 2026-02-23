import 'dart:convert';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AuxiliarProvider extends ChangeNotifier {
  List<Sesion> sesiones = [];
  Set<int> sesionesEvaluadas = {};

  bool loading = false;
  String? error;

  Future<void> getInfo() async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');

    loading = true;
    error = null;
    notifyListeners();

    try {
      await getSesiones(apikey);
      await getEvaluaciones(apikey);
    } catch (e) {
      error = e.toString();
      sesiones = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearInfo() {
    sesiones = [];
    sesionesEvaluadas = {};
    error = null;
    loading = false;
    notifyListeners();
  }

  Future<void> getSesiones(String? apikey) async {
    var url = Uri.parse('${Api.base}/api/3/sesionesporid');
    var response = await http.get(url, headers: {'Token': apikey!});

    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      sesiones = registros.map<Sesion>((row) => Sesion.fromJson(row)).toList();
    } else {
      throw 'No se pudieron cargar las sesiones. Comprueba tu conexión.';
    }
  }

  
  Future<void> getEvaluaciones(String? apikey) async {
    try {
      var url = Uri.parse('${Api.base}/api/3/evaluaciones?limit=2000');
      var response = await http.get(url, headers: {'Token': apikey!});
      if (response.statusCode == 200) {
        final registros = json.decode(response.body) as List;
        sesionesEvaluadas = registros
            .map((e) {
              final v = e['idsesion'];
              if (v is int) return v;
              if (v is String) return int.tryParse(v);
              return null;
            })
            .whereType<int>()
            .toSet();
      }
    } catch (_) {}
  }

  void marcarSesionEvaluada(int idsesion) {
    sesionesEvaluadas.add(idsesion);
    notifyListeners();
  }

  Future<List<Alumno>> getAlumnosDeGrupo(int idgrupo) async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');

    var url = Uri.parse(
        '${Api.base}/api/3/alumnos?filter[idgrupo]=$idgrupo&limit=200');
    var response = await http.get(url, headers: {'Token': apikey!});

    if (response.statusCode == 200) {
      final registros = json.decode(response.body) as List;
      return registros.map<Alumno>((row) => Alumno.fromJson(row)).toList();
    } else {
      throw 'No se pudo cargar la lista de alumnos.';
    }
  }

  Future<void> guardarAsistencia({
    required int idalumno,
    required int idsesion,
    required int idgrupo,
    required int? idprofesional,
    required int? idcompetencia,
    required bool asiste,
  }) async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    var url = Uri.parse('${Api.base}/api/3/evaluaciones');
    var response = await http.post(
      url,
      headers: {'Token': apikey!},
      body: {
        'idsesion': idsesion.toString(),
        'idprofesional': (idprofesional ?? 0).toString(),
        'idinteligencia': (idcompetencia ?? 0).toString(),
        'idalumno': idalumno.toString(),
        'fecha': formattedDate,
        'observaciones': 'Registro de asistencia',
        'adaptacion': '0',
        'comportamiento': '0',
        'nota': '0',
        'idcurso': '4',
        'noasiste': asiste ? '0' : '1',
      },
    );

    if (response.statusCode != 200) {
      throw 'No se pudo guardar la asistencia. Inténtalo de nuevo.';
    }
  }
}
