class Competencia {
  int? idcompetencia;
  String nombre = '';

  Competencia();

  Competencia.fromJson(Map<String, dynamic> json) {
    idcompetencia = int.parse(json['idcompetencia']);
    nombre = json['nombre'];
  }
}
