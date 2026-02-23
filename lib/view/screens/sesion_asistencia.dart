import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/auxiliar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SesionAsistenciaScreen extends StatefulWidget {
  final Sesion sesion;
  final List<Alumno> alumnos;

  const SesionAsistenciaScreen({
    super.key,
    required this.sesion,
    required this.alumnos,
  });

  @override
  State<SesionAsistenciaScreen> createState() => _SesionAsistenciaScreenState();
}

class _SesionAsistenciaScreenState extends State<SesionAsistenciaScreen> {
  late Map<int, bool> _asistencia;
  bool _guardando = false;
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _asistencia = {
      for (final a in widget.alumnos) a.idalumno!: true,
    };
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final provider = context.read<AuxiliarProvider>();
    try {
      for (final alumno in widget.alumnos) {
        final asiste = _asistencia[alumno.idalumno] ?? true;
        await provider.guardarAsistencia(
          idalumno: alumno.idalumno!,
          idsesion: widget.sesion.idsesion!,
          idgrupo: widget.sesion.idgrupo!,
          idprofesional: widget.sesion.idprofesional,
          idcompetencia: widget.sesion.idcompetencia,
          asiste: asiste,
        );
      }
      setState(() => _guardado = true);
      provider.marcarSesionEvaluada(widget.sesion.idsesion!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia guardada correctamente')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sesion;
    final alumnos = widget.alumnos;

    final totalAsisten = _asistencia.values.where((v) => v).length;
    final totalNoAsisten = _asistencia.values.where((v) => !v).length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sesion.grupo ?? sesion.competencia ?? 'Sesión',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${sesion.fecha ?? ''} ${sesion.hora ?? ''}'.trim(),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: alumnos.isEmpty
                ? const Center(child: Text('No hay alumnos en este grupo'))
                : ListView.builder(
                    itemCount: alumnos.length,
                    itemBuilder: (context, index) {
                      final alumno = alumnos[index];
                      final asiste = _asistencia[alumno.idalumno] ?? true;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: asiste
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              asiste ? Icons.check : Icons.close,
                              color: asiste ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(alumno.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                asiste ? 'Asiste' : 'No asiste',
                                style: TextStyle(
                                  color: asiste ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: asiste,
                                activeThumbColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    _asistencia[alumno.idalumno!] = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ElevatedButton.icon(
          onPressed: _guardando || _guardado ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_guardando
              ? 'Guardando...'
              : _guardado
                  ? 'Guardado ✓'
                  : 'Guardar asistencia'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }

  Widget _resumenItem(
      IconData icon, Color color, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text('$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
