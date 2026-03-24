class Competencia {
  int? idcompetencia;
  String nombre = '';

  Competencia();

  Competencia.fromJson(Map<String, dynamic> json) {

    final rawId = json['idinteligencia'] ?? json['idcompetencia'];
    idcompetencia = rawId != null ? int.tryParse(rawId.toString()) : null;
    nombre = json['nombre']?.toString() ?? '';
  }
  
}
