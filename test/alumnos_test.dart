import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alumno', () {
    test('fromJson crea una instancia de Alumno desde un mapa JSON', () {
      final json = {
        'nombre': 'Juan',
        'idalumno': 20,
        'idfamiliaalumno': 2,
        'idgrupo': 3
      };

      final alumno = Alumno.fromJson(json);

      expect(alumno.nombre, 'Juan');
      expect(alumno.idalumno, 20);
      expect(alumno.idfamiliaalumno, 2);
      expect(alumno.idgrupo, 3);
    });

    test('Convierte una lista de registros JSON en una lista de objetos Alumno',
        () {
      final registros = [
        {'nombre': 'Juan', 'idalumno': 20, 'idfamiliaalumno': 2, 'idgrupo': 3},
        {'nombre': 'Ana', 'idalumno': 21, 'idfamiliaalumno': 2, 'idgrupo': 3}
      ];

      final List<Alumno> alumnos =
          registros.map<Alumno>((row) => Alumno.fromJson(row)).toList();

      expect(alumnos.length, 2);
      expect(alumnos[0].nombre, 'Juan');
      expect(alumnos[1].nombre, 'Ana');
    });
  });
}
