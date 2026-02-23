import 'dart:convert';

import 'package:begabung_app/domain/entities/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Login {
  int idlogin = 0;
  int idfamiliaalumno = 0;
  int idprofesional = 0;
  bool mantenimiento = false;
  bool admin = false;
  bool auxiliar = false;
  String? user;
  String? apikey;

  Future<Login> login(String user, String password) async {
    var url = Uri.parse('${Api.base}/api/3/apikeyes?filter[description]=$user');
    var response = await http.get(url, headers: {'Token': password});

    var url2 = Uri.parse('${Api.base}/api/3/settings?filter[name]=begabung');
    var response2 = await http.get(url2, headers: {'Token': password});

    if (response.statusCode == 200) {
      final registro = json.decode(response.body);
      final registro2 = json.decode(response2.body);

      if (registro is List && registro.isEmpty) {
        throw 'Usuario o contraseña incorrectos';
      }

      if (registro[0]['apikey'] == password) {
        idlogin = registro[0]['id'];
        this.user = registro[0]['description'];
        apikey = registro[0]['apikey'];
        idfamiliaalumno = registro[0]['idfamiliaalumno'];
        idprofesional = registro[0]['idprofesional'];
        admin = registro[0]['admin'] == true || registro[0]['admin'] == 1;
        auxiliar =
            registro[0]['auxiliar'] == true || registro[0]['auxiliar'] == 1;

        if (registro2 is List && registro2.isNotEmpty) {
          var mant = json.decode(registro2[0]['properties']);
          mantenimiento = mant['mantenimiento'] == "1" ? true : false;
        }

        return this;
      } else {
        throw 'Usuario o contraseña incorrectos';
      }
    } else if (response.statusCode == 401) {
      throw 'Usuario o contraseña incorrectos';
    } else {
      throw 'No se pudo conectar con el servidor. Inténtalo de nuevo.';
    }
  }

  Future<Login?> loginId(String id, String apikey) async {
    var url = Uri.parse('${Api.base}/api/3/apikeyes/$id');
    var response = await http.get(url, headers: {'Token': apikey});

    var url2 = Uri.parse('${Api.base}/api/3/settings?filter[name]=begabung');
    var response2 = await http.get(url2, headers: {'Token': apikey});

    if (response.statusCode == 200) {
      final registro = json.decode(response.body);
      final registro2 = json.decode(response2.body);

      idlogin = registro['id'];
      user = registro['description'];
      this.apikey = registro['apikey'];
      idfamiliaalumno = registro['idfamiliaalumno'];
      idprofesional = registro['idprofesional'];
      admin = registro['admin'] == true || registro['admin'] == 1;
      auxiliar = registro['auxiliar'] == true || registro['auxiliar'] == 1;

      if (registro2 is List && registro2.isNotEmpty) {
        var mant = json.decode(registro2[0]['properties']);
        mantenimiento = mant['mantenimiento'] == "1" ? true : false;
      }
      return this;
    } else {
      return null;
    }
  }

  Future<bool> cambioPassword(String password) async {
    const storage = FlutterSecureStorage();
    String? apikey = await storage.read(key: 'apikey');
    String? id = await storage.read(key: 'id');
    var url = Uri.parse('${Api.base}/api/3/apikeyes/$id');
    var response = await http
        .put(url, headers: {'Token': apikey!}, body: {'apikey': password});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
