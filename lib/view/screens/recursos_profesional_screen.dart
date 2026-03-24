import 'dart:io';

import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:begabung_app/view/providers/recurso_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecursosProfesionalScreen extends StatefulWidget {
  const RecursosProfesionalScreen({super.key});

  @override
  State<RecursosProfesionalScreen> createState() =>
      _RecursosProfesionalScreenState();
}

class _RecursosProfesionalScreenState
    extends State<RecursosProfesionalScreen> {
  bool _loadRequested = false;

  void _mostrarDialogoSubirRecurso() {
    final profesionalProvider = context.read<ProfesionalProvider>();
    final idprofesional = profesionalProvider.profesional?.idprofesional;

    // Derivar inteligencias únicas de las sesiones impartidas
    final inteligencias = <int, String>{};
    for (final s in profesionalProvider.sesiones) {
      if (s.idcompetencia != null && s.competencia != null) {
        inteligencias[s.idcompetencia!] = s.competencia!;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SubirRecursoDialog(
        provider: context.read<RecursoProvider>(),
        idprofesional: idprofesional,
        inteligencias: inteligencias,
        onExito: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recurso guardado (pendiente de publicar)'),
              duration: Duration(seconds: 3),
            ),
          );
        },
        onError: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        },
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecursoProvider>();
    final idprofesional =
        context.watch<ProfesionalProvider>().profesional?.idprofesional;

    // Dispara carga cuando el profesional esté disponible
    if (!_loadRequested && idprofesional != null && !provider.isLoading) {
      _loadRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) provider.getRecursosPorProfesional(idprofesional);
      });
    }

    return Stack(
      children: [
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    onPressed: () {
                      final idprofesional = context
                          .read<ProfesionalProvider>()
                          .profesional
                          ?.idprofesional;
                      if (idprofesional != null) {
                        final recursoProvider = context.read<RecursoProvider>();

                        recursoProvider.clearRecursos();

                        recursoProvider.getRecursosPorProfesional(
                            idprofesional);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        else if (provider.recursos.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 210,
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
                    'Aún no has creado ningún recurso.\n¡Añade el primero con el botón +!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          )
        else
          RefreshIndicator(
            onRefresh: () async {
              final idprofesional = context
                  .read<ProfesionalProvider>()
                  .profesional
                  ?.idprofesional;

              if (idprofesional != null) {
                await context
                    .read<RecursoProvider>()
                    .getRecursosPorProfesional(idprofesional);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.recursos.length,
              itemBuilder: (_, i) {
                final r = provider.recursos[i];
                final publicado = r.publicado == true;

                final iconColor = publicado ? Colors.green : Colors.orange;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Ícono de estado (izquierda) ─────────────────
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            publicado
                                ? Icons.check_circle
                                : Icons.hourglass_top,
                            color: iconColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Datos del recurso (derecha) ─────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              Text(
                                r.titulo ?? 'Sin título',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              // Descripción
                              if (r.descripcion != null &&
                                  r.descripcion!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  r.descripcion!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              // Fecha
                              if (r.fechaPublicacion != null &&
                                  r.fechaPublicacion!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(children: [
                                  Icon(Icons.calendar_today,
                                      size: 12, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.fechaPublicacion!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ]),
                              ],
                              // Estado texto
                              const SizedBox(height: 6),
                              Text(
                                publicado
                                    ? 'Publicado'
                                    : 'Pendiente de publicar',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: iconColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        // FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'recursos_profesional_fab',
            onPressed: _mostrarDialogoSubirRecurso,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

// ── Dialog interno con su propio State ───────────────────────────────────────

class _SubirRecursoDialog extends StatefulWidget {
  final RecursoProvider provider;
  final int? idprofesional;
  final Map<int, String> inteligencias;   // id → nombre
  final VoidCallback onExito;
  final void Function(String) onError;

  const _SubirRecursoDialog({
    required this.provider,
    required this.onExito,
    required this.onError,
    required this.inteligencias,
    this.idprofesional,
  });

  @override
  State<_SubirRecursoDialog> createState() => _SubirRecursoDialogState();
}

class _SubirRecursoDialogState extends State<_SubirRecursoDialog> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  int? _idinteligenciaSeleccionada;    // ← nuevo
  bool _todos = false;
  bool _enviando = false;

  File? _ficheroFile;
  String? _nombreFichero;

  // Selecciones actuales
  Map<String, dynamic>? _familiaSeleccionada;
  Map<String, dynamic>? _sedeSeleccionada;
  final List<Map<String, dynamic>> _gruposSeleccionados = [];

  // Buscadores
  final _familiaCtrl = TextEditingController();
  final _sedeCtrl = TextEditingController();
  final _grupoCtrl = TextEditingController();

  List<Map<String, dynamic>> _todasFamilias = [];
  List<Map<String, dynamic>> _todasSedes = [];
  List<Map<String, dynamic>> _todosGrupos = [];
  List<Map<String, dynamic>> _familiasSugeridas = [];
  List<Map<String, dynamic>> _sedesSugeridas = [];
  List<Map<String, dynamic>> _gruposSugeridos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precargarDatos());
  }

  Future<void> _precargarDatos() async {
    final familias = await widget.provider.buscarFamilias('');
    final sedes = await widget.provider.buscarSedes('');
    final grupos = await widget.provider.buscarGrupos('');
    if (!mounted) return;
    setState(() {
      _todasFamilias = familias;
      _todasSedes = sedes;
      _todosGrupos = grupos;
    });
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    _familiaCtrl.dispose();
    _sedeCtrl.dispose();
    _grupoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBuscarFamilia(String q) async {

  final resultados = await widget.provider.buscarFamilias(q);

  setState(() {
    _familiasSugeridas = resultados;
  });

}

  void _onBuscarSede(String q) {
    final query = q.toLowerCase();
    setState(() {
      _sedesSugeridas = _todasSedes
          .where((m) =>
              m['nombre']?.toString().toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  void _onBuscarGrupo(String q) {
    final query = q.toLowerCase();
    setState(() {
      _gruposSugeridos = _todosGrupos
          .where((m) =>
              m['nombre']?.toString().toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  Future<void> _pickFichero() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      final file = result.files.single;

      setState(() {
        _ficheroFile = File(file.path!);
        _nombreFichero = file.name;
      });
    }
  }

  Future<void> _publicar() async {
    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    setState(() => _enviando = true);

    // Grupos (hasta 4)
    final grupoIds = _gruposSeleccionados
        .map((g) => int.tryParse(g['idgrupo']?.toString() ?? ''))
        .whereType<int>()
        .toList();

    final error = await widget.provider.subirRecurso(
      titulo: titulo,
      idprofesional: widget.idprofesional,
      idinteligencia: _idinteligenciaSeleccionada,
      descripcion: _descCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      fichero: _ficheroFile,
      todos: _todos ? 1 : 0,
      idfamiliaalumno: _familiaSeleccionada != null
          ? int.tryParse(
              _familiaSeleccionada!['idfamiliaalumno']?.toString() ?? '')
          : null,
      idsede: _sedeSeleccionada != null
          ? int.tryParse(_sedeSeleccionada!['idsede']?.toString() ?? '')
          : null,
      idgrupo: grupoIds.isNotEmpty ? grupoIds[0] : null,
      idgrupo2: grupoIds.length > 1 ? grupoIds[1] : null,
      idgrupo3: grupoIds.length > 2 ? grupoIds[2] : null,
      idgrupo4: grupoIds.length > 3 ? grupoIds[3] : null,
    );

    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();

    if (error == null) {
      widget.onExito();
    } else {
      widget.onError(error);
    }
  }

  // ── Buscador genérico ───────────────────────────────────────────────────
  // ⚠️  NO usar ListView.builder aquí dentro: causa ANR por constraints infinitas
  //    dentro de SingleChildScrollView + AlertDialog.

  Widget _buscador({
    required String label,
    required TextEditingController ctrl,
    required List<Map<String, dynamic>> sugerencias,
    required void Function(String) onChanged,
    required String Function(Map<String, dynamic>) displayText,
    required void Function(Map<String, dynamic>) onSelected,
    Widget? clearButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar...',
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: clearButton,
          ),
        ),
        if (sugerencias.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            // Lista estática — máximo 5 items, sin ListView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sugerencias.take(5).map((item) {
                return InkWell(
                  onTap: () => onSelected(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayText(item),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Dialog con tamaño explícito para evitar constraints infinitas
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity, // acotado por insetPadding
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera ──────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nuevo recurso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Contenido scrollable ──────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text('Título *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un título...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    const Text('Descripción',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Descripción opcional...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // URL
                    const Text('URL (opcional)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlCtrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Fichero
                    const Text('Adjuntar fichero',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _nombreFichero ?? 'Seleccionar fichero',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: _pickFichero,
                    ),
                    if (_nombreFichero != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_nombreFichero!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.green),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 14),

                    // Inteligencia (derivada de las sesiones impartidas)
                    if (widget.inteligencias.isNotEmpty) ...[ 
                      const Text('Inteligencia',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _idinteligenciaSeleccionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: 'Selecciona una inteligencia',
                        ),
                        items: widget.inteligencias.entries
                            .map((e) => DropdownMenuItem<int>(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _idinteligenciaSeleccionada = v),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Para todos
                    Row(children: [
                      Checkbox(
                        value: _todos,
                        onChanged: (v) => setState(() {
                          _todos = v ?? false;
                          if (_todos) {
                            _familiaSeleccionada = null;
                            _sedeSeleccionada = null;
                            _gruposSeleccionados.clear();
                            _familiaCtrl.clear();
                            _sedeCtrl.clear();
                            _grupoCtrl.clear();
                            _familiasSugeridas = [];
                            _sedesSugeridas = [];
                            _gruposSugeridos = [];
                          }
                        }),
                      ),
                      const Text('Para todos los alumnos'),
                    ]),

                    // Buscadores (ocultos si todos=true)
                    if (!_todos) ...[
                      const SizedBox(height: 10),

                      // Familia
                      _buscador(
                        label: 'Familia alumno',
                        ctrl: _familiaCtrl,
                        sugerencias: _familiasSugeridas,
                        onChanged: _onBuscarFamilia,
                        displayText: (m) =>
                            m['nombre']?.toString() ??
                            '#${m['idfamiliaalumno']}',
                        onSelected: (m) => setState(() {
                          _familiaSeleccionada = m;
                          _familiaCtrl.text = m['nombre']?.toString() ?? '';
                          _familiasSugeridas = [];
                        }),
                        clearButton: _familiaSeleccionada != null
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() {
                                  _familiaSeleccionada = null;
                                  _familiaCtrl.clear();
                                }),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Sede
                      _buscador(
                        label: 'Sede',
                        ctrl: _sedeCtrl,
                        sugerencias: _sedesSugeridas,
                        onChanged: _onBuscarSede,
                        displayText: (m) =>
                            m['nombre']?.toString() ?? '#${m['idsede']}',
                        onSelected: (m) => setState(() {
                          _sedeSeleccionada = m;
                          _sedeCtrl.text = m['nombre']?.toString() ?? '';
                          _sedesSugeridas = [];
                        }),
                        clearButton: _sedeSeleccionada != null
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() {
                                  _sedeSeleccionada = null;
                                  _sedeCtrl.clear();
                                }),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Grupos
                      _buscador(
                        label: 'Grupos (máx. 4)',
                        ctrl: _grupoCtrl,
                        sugerencias: _gruposSeleccionados.length < 4
                            ? _gruposSugeridos
                            : [],
                        onChanged: _onBuscarGrupo,
                        displayText: (m) =>
                            m['nombre']?.toString() ?? '#${m['idgrupo']}',
                        onSelected: (m) {
                          if (_gruposSeleccionados.length >= 4) return;
                          final ya = _gruposSeleccionados
                              .any((g) => g['idgrupo'] == m['idgrupo']);
                          if (!ya) {
                            setState(() {
                              _gruposSeleccionados.add(m);
                              _grupoCtrl.clear();
                              _gruposSugeridos = [];
                            });
                          }
                        },
                      ),
                      if (_gruposSeleccionados.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _gruposSeleccionados
                              .map((g) => Chip(
                                    label: Text(g['nombre']?.toString() ?? '',
                                        style: const TextStyle(fontSize: 12)),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 14),
                                    onDeleted: () => setState(
                                        () => _gruposSeleccionados.remove(g)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Botones ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _enviando ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _enviando ? null : _publicar,
                    child: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
