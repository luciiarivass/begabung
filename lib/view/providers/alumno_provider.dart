import 'dart:convert';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:flutter/material.dart' hide Feedback;
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
  List<Feedback> feedbacks = [];
  Set<int> sesionesEvaluadas = {};

  /// GET con reintentos automáticos ante 429 o errores de conexión.
  Future<http.Response> _getWithRetry(Uri url, String apikey,
      {int maxRetries = 5}) async {
    int delayMs = 1000;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(url, headers: {'Token': apikey});
        if (response.statusCode != 429) return response;
        if (attempt == maxRetries) return response;
        print('⚠️ 429 → reintento ${attempt + 1}/$maxRetries en ${delayMs}ms ($url)');
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        print('⚠️ Error de red ($e) → reintento ${attempt + 1}/$maxRetries en ${delayMs}ms');
      }
      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs = (delayMs * 2).clamp(0, 30000);
    }
    throw 'Error inesperado en _getWithRetry';
  }
  
/// COMPROBAR QUE PASA CON EL INICIO DE SESION COMO ALUMNO 


  Future<void> getInfo(int idalumno, {bool force = false}) async {
    const storage = FlutterSecureStorage();
    final apikey = await storage.read(key: 'apikey');

    await getAlumnoInfo(idalumno, apikey);
    notifyListeners(); // actualiza nombre en AppBar al instante

    await Future.delayed(const Duration(milliseconds: 300));
    await getAlumnoSesiones(apikey);
    notifyListeners(); // muestra sesiones en cuanto llegan

    await Future.delayed(const Duration(milliseconds: 300));
    await getAlumnoEvaluaciones(apikey);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    await getAlumnoNotificaciones(apikey);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    await getFeedbacks(apikey);
    notifyListeners();

    print(' getInfo completado: ${alumno?.nombre}, ${sesiones.length} sesiones');
  }

  void clearInfo() {
    alumno = null;
    grupo = null;
    competencia = null;
    sesiones = [];
    evaluaciones = [];
    notificaciones = [];
    feedbacks = [];
    sesionesEvaluadas = {};
    notifyListeners();
  }

  Future<void> getAlumnoInfo(int idalumno, String? apikey) async {
    final url = Uri.parse('${Api.base}/api/3/alumnos/$idalumno');
    final response = await _getWithRetry(url, apikey!);
    if (response.statusCode == 200) {
      alumno = Alumno.fromJsonFS(json.decode(response.body));
    } else {
      print(' getAlumnoInfo → ${response.statusCode}: ${response.body}');
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoSesiones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/sesionesporid?idalumno=${alumno?.idalumno}');
    final response = await _getWithRetry(url, apikey!);
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      grupo = registros[0]['nombreGrupo'];
      sesiones = registros.map<Sesion>((row) => Sesion.fromJson(row)).toList();
    } else {
      print(' getAlumnoSesiones → ${response.statusCode}: ${response.body}');
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoEvaluaciones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/evaluacionesporid?idalumno=${alumno?.idalumno}');
    final response = await _getWithRetry(url, apikey!);
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      evaluaciones =
          registros.map<Evaluacion>((row) => Evaluacion.fromJson(row)).toList();
    } else {
      print(' getAlumnoEvaluaciones → ${response.statusCode}: ${response.body}');
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getAlumnoNotificaciones(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/notificaciones?idalumno=${alumno?.idalumno}');
    final response = await _getWithRetry(url, apikey!);
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      notificaciones = registros
          .map<Notificacion>((row) => Notificacion.fromJson(row))
          .toList();
    } else {
      print(' getAlumnoNotificaciones → ${response.statusCode}: ${response.body}');
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  Future<void> getFeedbacks(String? apikey) async {
    final url = Uri.parse(
        '${Api.base}/api/3/feedbacks?filter[idalumno]=${alumno?.idalumno}');
    final response = await _getWithRetry(url, apikey!);
    print('GET /feedback → ${response.statusCode}');
    if (response.statusCode == 200) {
      final registros = json.decode(response.body);
      feedbacks = registros
          .map<Feedback>((row) => Feedback.fromJson(row))
          .toList();
      sesionesEvaluadas = feedbacks.map((f) => f.idsesion ?? -1).toSet();
    }
  }


  Future<String?> guardarFeedback({
    required int idsesion,
    required int idgrupo,
    required int idprofesional,
    required int notaProfe,
    required int notaSesion,
    required String observaciones,
  }) async {
    const storage = FlutterSecureStorage();
    final apikey = await storage.read(key: 'apikey');

    final now = DateTime.now();
    final fecha =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('${Api.base}/api/3/feedbacks');
    final response = await http.post(
      url,
      headers: {'Token': apikey!},
      body: {
        'idalumno': alumno!.idalumno.toString(),
        'idsesion': idsesion.toString(),
        'idgrupo': idgrupo.toString(),
        'idprofesional': idprofesional.toString(),
        'nota_profesional': notaProfe.toString(),
        'nota_sesion': notaSesion.toString(),
        'observaciones': observaciones,
        'fecha': fecha,
      },
    );

    print('POST /feedback → ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Recargar feedbacks
      await getFeedbacks(apikey);
      notifyListeners();
      return null;
    }
    try {
      final decoded = json.decode(response.body);
      return decoded['message'] ?? decoded['error'] ?? 'Error ${response.statusCode}';
    } catch (_) {
      return 'Error ${response.statusCode}: ${response.body}';
    }
  }
}
