import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/recursos.dart';
import 'package:begabung_app/view/providers/recurso_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecursosAlumnoScreen extends StatefulWidget {
  final Alumno alumno;
  final int? idinteligencia;
  final String? nombreInteligencia;
  final VoidCallback? onBack;

  const RecursosAlumnoScreen({
    super.key,
    required this.alumno,
    this.idinteligencia,
    this.nombreInteligencia,
    this.onBack,
  });

  @override
  State<RecursosAlumnoScreen> createState() => _RecursosAlumnoScreenState();
}

class _RecursosAlumnoScreenState extends State<RecursosAlumnoScreen> {
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        throw 'No se pudo abrir la URL';
      }
    } catch (e) {
      debugPrint('Error abriendo URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecursoProvider>();
    final recursos = widget.idinteligencia != null
        ? provider.filtrarPorInteligencia(widget.idinteligencia!)
        : provider.recursosAlumno;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(widget.nombreInteligencia ?? 'Recursos'),
        centerTitle: true,
      ),
      body: _buildBody(provider, recursos),
    );
  }

  Widget _buildBody(RecursoProvider provider, List<Recurso> recursos) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context
                    .read<RecursoProvider>()
                    .loadRecursosAlumno(widget.alumno);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (recursos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'No hay recursos disponibles para esta inteligencia.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recursos.length,
      itemBuilder: (_, i) => _RecursoCard(
        recurso: recursos[i],
        onAbrirUrl: _abrirUrl,
      ),
    );
  }
}

class _RecursoCard extends StatelessWidget {
  final Recurso recurso;
  final Future<void> Function(String url) onAbrirUrl;

  const _RecursoCard({
    required this.recurso,
    required this.onAbrirUrl,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecursoProvider>();

    final ficheroUrl = (recurso.fichero != null && recurso.fichero!.isNotEmpty)
        ? '${Api.base}/MyFiles/${recurso.fichero}'
        : null;

    final urlExterna =
        (recurso.url != null && recurso.url!.isNotEmpty) ? recurso.url : null;

    final tipo = ficheroUrl != null ? _getTipoArchivo(ficheroUrl) : null;

    final nombreProfesional =
        provider.getNombreProfesional(recurso.idprofesional) ?? 'Profesional';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧠 NOMBRE PROFESIONAL (AÑADIDO)
            Text(
              nombreProfesional,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            /// ── Título
            Text(
              recurso.titulo ?? 'Sin título',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            /// ── Descripción
            if (recurso.descripcion != null &&
                recurso.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(recurso.descripcion!),
            ],

            const SizedBox(height: 10),

            /// ── IMAGEN
            if (ficheroUrl != null && tipo == 'imagen')
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImagenViewerScreen(url: ficheroUrl),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ficheroUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
            if (ficheroUrl != null && tipo == 'pdf')
              _FicheroTile(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                nombre: recurso.fichero!.split('/').last,
                onTap: () => onAbrirUrl(ficheroUrl),
              ),

            /// ── OTROS ARCHIVOS
            if (ficheroUrl != null && tipo == 'otro')
              _FicheroTile(
                icon: Icons.insert_drive_file_rounded,
                iconColor: Colors.blueGrey,
                nombre: recurso.fichero!.split('/').last,
                onTap: () => onAbrirUrl(ficheroUrl),
              ),

            /// ── URL EXTERNA
            if (urlExterna != null) ...[
              const SizedBox(height: 8),
              _FicheroTile(
                icon: Icons.link_rounded,
                iconColor: Colors.blue,
                nombre: urlExterna,
                onTap: () => onAbrirUrl(urlExterna),
              ),
            ],

            const SizedBox(height: 8),
            const Divider(),

            /// ── FECHA
            if (recurso.fechaPublicacion != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatFecha(recurso.fechaPublicacion!),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha.replaceFirst(' ', 'T'));
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return fecha;
    }
  }
}

class _FicheroTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String nombre;
  final VoidCallback onTap;

  const _FicheroTile({
    required this.icon,
    required this.iconColor,
    required this.nombre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nombre,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class ImagenViewerScreen extends StatelessWidget {
  final String url;

  const ImagenViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}

String _getTipoArchivo(String url) {
  final ext = url.split('.').last.toLowerCase().split('?').first;
  if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) return 'imagen';
  if (ext == 'pdf') return 'pdf';
  return 'otro';
}
