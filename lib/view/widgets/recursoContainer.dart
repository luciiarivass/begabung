import 'dart:io';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/recursos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';

class RecursoCard extends StatelessWidget {
  final Recurso recurso;

  const RecursoCard({super.key, required this.recurso});

  IconData _iconoArchivo(String nombre) {
    final lower = nombre.toLowerCase();

    if (lower.endsWith(".pdf")) return Icons.picture_as_pdf;
    if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")) {
      return Icons.image;
    }
    if (lower.endsWith(".doc") || lower.endsWith(".docx")) {
      return Icons.description;
    }

    return Icons.insert_drive_file;
  }

  Future<void> descargarArchivo(BuildContext context) async {

    if (recurso.fichero == null) return;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'apikey');

    final url = Uri.parse('${Api.base}/MyFiles/${recurso.fichero}');

    try {

      final response = await http.get(
        url,
        headers: {'Token': token ?? ''},
      );

      if (response.statusCode == 200) {

        final dir = await getTemporaryDirectory();

        final fileName = recurso.fichero!.split('/').last;

        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        await OpenFilex.open(filePath);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error descargando archivo: ${response.statusCode}")),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    final nombreArchivo = recurso.fichero?.split('/').last ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// Título
            Text(
              recurso.titulo ?? "Sin título",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            if (recurso.descripcion != null && recurso.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(recurso.descripcion!),
            ],

            const SizedBox(height: 10),

            /// Archivo
            if (recurso.fichero != null && recurso.fichero!.isNotEmpty)

              Row(
                children: [

                  Icon(
                    _iconoArchivo(nombreArchivo),
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      nombreArchivo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// BOTÓN ABRIR
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => descargarArchivo(context),
                  ),

                  /// BOTÓN DESCARGAR
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => descargarArchivo(context),
                  ),

                ],
              ),

          ],
        ),
      ),
    );
  }
}