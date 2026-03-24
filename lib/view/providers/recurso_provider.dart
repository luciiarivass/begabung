import 'dart:convert';
import 'dart:io';

import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/competencia.dart';
import 'package:begabung_app/domain/entities/recursos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class RecursoProvider extends ChangeNotifier {
  List<Recurso> recursos = [];
  List<Recurso> recursosAlumno = [];
  bool isLoading = false;
  String? error = null;
  Map<int, Competencia> inteligencias = {};

  Future<String> _getApiKey() async {
    const storage = FlutterSecureStorage();
    final apikey = await storage.read(key: 'apikey');
    if (apikey == null) throw 'API key no encontrada';
    return apikey;
  }

  /// 📥 RECURSOS PROFESIONAL
  Future<void> getRecursosPorProfesional(int idprofesional) async {
    final apikey = await _getApiKey();

    final url = Uri.parse(
        '${Api.base}/api/3/recursos?filter[idprofesional]=$idprofesional');

    final response = await http.get(url, headers: {'Token': apikey});

    if (response.statusCode == 200) {
      final registros = json.decode(response.body);

      recursos =
          registros.map<Recurso>((row) => Recurso.fromJson(row)).toList();

      notifyListeners();
    } else {
      throw 'Error ${response.statusCode}: ${response.body}';
    }
  }

  /// 📥 RECURSOS ALUMNO
  Future<void> loadRecursosAlumno(Alumno alumno) async {
    final apikey = await _getApiKey();
    print('DATA INTELIGENCIAS: ${inteligencias.length} recursos: ${recursosAlumno.length}');
    final url = Uri.parse('${Api.base}/api/3/recursos');

    final response = await http.get(url, headers: {'Token': apikey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final todos = data.map<Recurso>((row) => Recurso.fromJson(row)).toList();

      recursosAlumno = todos.where((r) {
        if (r.publicado != true) return false;

        if (r.todos == true) return true;

        if (alumno.idgrupo != null &&
            (r.idgrupo == alumno.idgrupo ||
                r.idgrupo2 == alumno.idgrupo ||
                r.idgrupo3 == alumno.idgrupo ||
                r.idgrupo4 == alumno.idgrupo)) {
          return true;
        }

        if (r.idsede != null && r.idsede == alumno.idsede) return true;

        if (r.idfamiliaalumno != null &&
            r.idfamiliaalumno == alumno.idfamiliaalumno) {
          return true;
        }

        return false;
      }).toList();

      notifyListeners();
    } else {
      print('Error cargando recursos: ${response.statusCode} ${response.body}');
      throw 'Error ${response.statusCode} al cargar recursos';
    }
  }

  Future<void> getInteligencias() async {
    final apikey = await _getApiKey();

    final url = Uri.parse('${Api.base}/api/3/inteligencias');

    final response = await http.get(url, headers: {'Token': apikey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final map = <int, Competencia>{};

      for (var item in data) {
        final comp = Competencia.fromJson(item);
        if (comp.idcompetencia != null) {
          map[comp.idcompetencia!] = comp;
        }
      }

      inteligencias = map;
      notifyListeners();
    } else {
      print(error);
    }
  }

  /// 🧠 NOMBRE INTELIGENCIA
  String getNombreInteligencia(int id) {
    return inteligencias[id]?.nombre ?? 'Sin nombre';
  }

  Map<int, String> getInteligenciasDeRecursos() {
    final map = <int, String>{};

    for (final r in recursosAlumno) {
      if (r.publicado == true && r.idinteligencia != null) {
        final id = r.idinteligencia!;
        map[id] = getNombreInteligencia(id);
      }
    }

    return map;
  }

  /// 🔍 BUSCADOR
  Future<List<Map<String, dynamic>>> _fetchList(String endpoint) async {
    try {
      final apikey = await _getApiKey();
      final uri = Uri.parse('${Api.base}$endpoint');

      final response = await http.get(uri, headers: {'Token': apikey});

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<List<Map<String, dynamic>>> buscarFamilias(String query) {
    final filtro =
        query.isNotEmpty ? '?filter[nombre]=${Uri.encodeComponent(query)}' : '';
    return _fetchList('/api/3/familiasalumnos$filtro');
  }

  Future<List<Map<String, dynamic>>> buscarGrupos(String query) {
    final filtro =
        query.isNotEmpty ? '?filter[nombre]=${Uri.encodeComponent(query)}' : '';
    return _fetchList('/api/3/grupos$filtro');
  }

  Future<List<Map<String, dynamic>>> buscarSedes(String query) {
    final filtro =
        query.isNotEmpty ? '?filter[nombre]=${Uri.encodeComponent(query)}' : '';
    return _fetchList('/api/3/sedes$filtro');
  }

  /// ⬆️ SUBIR RECURSO
  Future<String?> subirRecurso({
    required String titulo,
    int? idprofesional,
    int? idinteligencia,
    String? descripcion,
    String? url,
    File? fichero,
    int? idgrupo,
    int? idgrupo2,
    int? idgrupo3,
    int? idgrupo4,
    int? idsede,
    int? idfamiliaalumno,
    int todos = 0,
  }) async {
    final apikey = await _getApiKey();
    final uri = Uri.parse('${Api.base}/api/3/recursos');

    if (todos == 0 &&
        idgrupo == null &&
        idgrupo2 == null &&
        idgrupo3 == null &&
        idgrupo4 == null &&
        idsede == null &&
        idfamiliaalumno == null) {
      return 'Selecciona al menos un destinatario';
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers['Token'] = apikey
      ..fields['titulo'] = titulo
      ..fields['todos'] = todos.toString()
      ..fields['publicado'] = '0';

    if (idprofesional != null) {
      request.fields['idprofesional'] = idprofesional.toString();
    }

    if (idinteligencia != null) {
      request.fields['idinteligencia'] = idinteligencia.toString();
    }

    if (descripcion != null && descripcion.isNotEmpty) {
      request.fields['descripcion'] = descripcion;
    }

    if (url != null && url.isNotEmpty) {
      request.fields['url'] = url;
    }

    if (todos == 0) {
      if (idgrupo != null) request.fields['idgrupo'] = idgrupo.toString();
      if (idgrupo2 != null) request.fields['idgrupo2'] = idgrupo2.toString();
      if (idgrupo3 != null) request.fields['idgrupo3'] = idgrupo3.toString();
      if (idgrupo4 != null) request.fields['idgrupo4'] = idgrupo4.toString();
      if (idsede != null) request.fields['idsede'] = idsede.toString();
      if (idfamiliaalumno != null) {
        request.fields['idfamiliaalumno'] = idfamiliaalumno.toString();
      }
    }

    if (fichero != null) {
      final mimeType =
          lookupMimeType(fichero.path) ?? 'application/octet-stream';

      request.files.add(await http.MultipartFile.fromPath(
        'fichero',
        fichero.path,
        filename: fichero.path.split('/').last,
        contentType: MediaType(
          mimeType.split('/')[0],
          mimeType.split('/')[1],
        ),
      ));
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (idprofesional != null) {
          await getRecursosPorProfesional(idprofesional);
        }
        return null;
      }

      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      return 'Error de red: $e';
    }
  }

  void clearRecursos() {
    recursos = [];
    recursosAlumno = [];
    isLoading = false;
    error = null;
    notifyListeners();
  }

  List<Recurso> filtrarPorInteligencia(int idInteligencia) {
    return recursosAlumno
        .where((r) => r.idinteligencia == idInteligencia && r.publicado == true)
        .toList();
  }

  Map<int, String> nombresProfesionales = {};

  String? getNombreProfesional(int? id) {
    if (id == null) return null;
    return nombresProfesionales[id];
  }
}
