import 'dart:convert';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AdminProvider extends ChangeNotifier {
  List<Sesion> sesiones = [];
  List<Grupo> grupos = [];
  List<Evaluacion> evaluaciones = [];

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
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }
}

  // Future<void> getSesiones(String? apikey) async {
  //   var url =
  //       Uri.parse('https://begabung.es/gestion/api/3/sesiones?limit=1000');
  //   var response = await http.get(url, headers: {'Token': apikey!});
  //   if (response.statusCode == 200) {
  //     final registros = json.decode(response.body);
  //     sesiones = registros.map<Sesion>((row) => Sesion.fromJson(row)).toList();
  //   } else {
  //     throw 'No se han encontrado sesiones para el grupo';
  //   }
  // }

  // completarSesiones(String? apikey) async {
  //   for (Sesion sesion in sesiones) {
  //     sesion.hora = sesion.fecha!.substring(11, 16);
  //     var url = Uri.parse(
  //         'https://begabung.es/gestion/api/3/inteligencias/${sesion.idcompetencia}');
  //     var response = await http.get(url, headers: {'Token': apikey!});
  //     if (response.statusCode == 200) {
  //       final registro = json.decode(response.body);
  //       sesion.competencia = registro['nombre'];
  //     } else {
  //       throw 'No se ha encontrado la competencia';
  //     }
  //     url = Uri.parse(
  //         'https://begabung.es/gestion/api/3/profesionales/${sesion.idprofesional}');
  //     response = await http.get(url, headers: {'Token': apikey});
  //     if (response.statusCode == 200) {
  //       final registro = json.decode(response.body);
  //       sesion.profesional.nombre = registro['nombre'];
  //       sesion.profesional.bio = registro['bio'];
  //     } else {
  //       throw 'No se ha encontrado el profesional';
  //     }
  //     url = Uri.parse(
  //         'https://begabung.es/gestion/api/3/grupos/${sesion.idgrupo}');
  //     var responseGrupo = await http.get(url, headers: {'Token': apikey});
  //     if (responseGrupo.statusCode == 200) {
  //       final registro = json.decode(responseGrupo.body);
  //       sesion.grupo = registro['nombre'];
  //     } else {
  //       throw 'No se ha encontrado el profesional';
  //     }
  //   }
  // }

