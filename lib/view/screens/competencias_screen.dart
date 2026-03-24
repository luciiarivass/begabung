import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:begabung_app/view/providers/recurso_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompetenciasScreen extends StatefulWidget {
  final void Function(int idInteligencia, String nombre)? onSelectInteligencia;

  const CompetenciasScreen({super.key, this.onSelectInteligencia});

  @override
  State<CompetenciasScreen> createState() => _CompetenciasScreenState();
}

class _CompetenciasScreenState extends State<CompetenciasScreen> {
  bool _loadRequested = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecursoProvider>();
    final alumno = context.watch<AlumnoProvider>().alumno;
    final colorScheme = Theme.of(context).colorScheme;

    if (!_loadRequested && alumno != null && !provider.isLoading) {
      _loadRequested = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          await provider.loadRecursosAlumno(alumno);
          await provider.getInteligencias();
        } catch (e) {
          if (mounted) setState(() => _error = e.toString());
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mis Recursos'),
        centerTitle: true,
      ),
      body: _buildBody(provider, colorScheme),
    );
  }

  Widget _buildBody(RecursoProvider provider, ColorScheme colorScheme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 52, color: Colors.black38),
              const SizedBox(height: 16),
              const Text(
                'No se pudieron cargar los recursos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _loadRequested = false;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar recursos publicados por idinteligencia
    final Map<int?, List> grouped = {};

    for (final r in provider.recursosAlumno) {
      if (r.publicado != true) continue;
      final key = r.idinteligencia; // puede ser null → "Sin inteligencia"
      grouped.putIfAbsent(key, () => []).add(r);
    }

    if (grouped.isEmpty) {
      return _buildEmpty(colorScheme);
    }

    // Construir lista de entradas: (id, nombre, recursos)
    final entries = grouped.entries.map((e) {
      final id = e.key;
      final nombre =
          id != null ? provider.getNombreInteligencia(id) : 'Sin inteligencia';
      return _InteligenciaEntry(id: id, nombre: nombre, recursos: e.value);
    }).toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _InteligenciaCard(
              entry: entry,
              onTap: () => _navigateTo(entry),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme) {
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
          Text(
            'Aún no hay recursos disponibles\npara este alumno.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(_InteligenciaEntry entry) {
    final alumno = context.read<AlumnoProvider>().alumno!;
    GoRouter.of(context).push(
      '/recursos-alumno',
      extra: {
        'alumno': alumno,
        'nombre': entry.nombre,
        'idinteligencia': entry.id,
      },
    );
  }
}

// ─────────────────────────────────────────────
// Modelo auxiliar de entrada
// ─────────────────────────────────────────────
class _InteligenciaEntry {
  final int? id;
  final String nombre;
  final List recursos;

  const _InteligenciaEntry({
    required this.id,
    required this.nombre,
    required this.recursos,
  });
}

// ─────────────────────────────────────────────
// Tarjeta individual de inteligencia
// ─────────────────────────────────────────────
class _InteligenciaCard extends StatelessWidget {
  final _InteligenciaEntry entry;
  final VoidCallback onTap;

  const _InteligenciaCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const icon = Icons.psychology_rounded;
    final count = entry.recursos.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono con fondo semitransparente
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                // Nombre
                Text(
                  entry.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Badge con número de recursos
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'recurso' : 'recursos'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
