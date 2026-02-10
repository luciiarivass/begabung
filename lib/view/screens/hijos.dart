import 'dart:io';

import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Para obtener el nombre del archivo
import 'package:mime/mime.dart'; // Para obtener el tipo MIME del archivo
import 'package:http_parser/http_parser.dart'; // Para el tipo de archivo al subirlo

class HijosScreen extends StatefulWidget {
  static const String route = 'hijos_screen';
  List<Alumno> alumnos = [];

  //HijosScreen({super.key, required this.alumnos});
  HijosScreen({super.key});

  @override
  State<HijosScreen> createState() => _HijosScreenState();
}

class _HijosScreenState extends State<HijosScreen> {
  List alumnos = [];
  String textoImagen =
      '''Por favor, sube una fotografía reciente de tu hijo/a. Los docentes sólo podrán evaluarle si tienen una foto donde se le identifique claramente.
      
      Esta imagen se almacenará de forma segura en nuestros servidores. No se compartirá con terceros; solo será utilizada para facilitar la labor de los docentes. La privacidad de tu hijo/a es nuestra máxima prioridad. Gracias''';

  @override
  void initState() {
    super.initState();
    _loadAlumnos();
    //alumnos = widget.alumnos;
  }

  _loadAlumnos() async {
    List loadedAlumnos = await getAlumnos();
    setState(() {
      alumnos = loadedAlumnos;
    });
  }

  Future<List> getAlumnos() async {
    const storage = FlutterSecureStorage();
    String? idfamilia = await storage.read(key: 'idfamilia');
    String? apikey = await storage.read(key: 'apikey');
    return await Familiaalumno.getAlumnos(int.parse(idfamilia!), apikey!);
  }

  Future<ImageProvider>? _loadImage(String baseUrl) async {
    final formats = ['jpg', 'jpeg', 'png'];

    for (var format in formats) {
      final url =
          '${Api.base}/api/3/MyFiles/Public/$baseUrl.$format?${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return NetworkImage(url);
      }
    }

    return const AssetImage('lib/assets/images/logoios.jpg');
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      //setState(() {
      //alumnos[index].imagen = File(pickedFile.path);
      //});
      await _uploadImage(File(pickedFile.path), alumnos[index].idalumno!);
    }
  }

  Future<void> _uploadImage(File imageFile, int idalumno) async {
    var uploadUrl = Uri.parse('${Api.base}/api/3/fotos');

    try {
      // Obtener el tipo MIME del archivo
      final mimeType = lookupMimeType(imageFile.path);

      // Crear la solicitud Multipart
      var request = http.MultipartRequest('POST', uploadUrl);

      // Añadir el archivo al request
      request.files.add(await http.MultipartFile.fromPath(
        'file', // El nombre del campo en el servidor (ej. $_FILES['file'] en PHP)
        imageFile.path,
        contentType: MediaType(
            mimeType!.split('/')[0], mimeType.split('/')[1]), // Tipo MIME
        filename:
            '$idalumno.${mimeType.split('/')[1]}', // Nombre del archivo en el servidor
      ));

      request.headers['Token'] = 'password';

      // Enviar la solicitud
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Imagen subida exitosamente.");
        setState(() {});
        // Aquí podría vincular la imagen con el registro de la base de datos en FacturaScripts
      } else {
        print("Error al subir la imagen: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error durante la subida: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: alumnos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, -60.0)
                  ..rotateZ(0.1),
                child: Container(
                  width: 492,
                  height: 524,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: AssetImage('lib/assets/images/cabeza 1.png'),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(196),
                    ),
                    /*shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],*/
                  ),
                ),
              ),
              ListView.builder(
                  padding: const EdgeInsets.all(40),
                  itemCount: alumnos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: GestureDetector(
                        child: Container(
                          width: 328,
                          //height: 300,
                          decoration: ShapeDecoration(
                            image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'lib/assets/images/simbolos 2.png')),
                            color: index == 1
                                ? const Color(0xBA6D1C74)
                                : const Color(0xBA1C4474),
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(width: 1),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () => _pickImage(index),
                                  child: FutureBuilder<ImageProvider>(
                                    future: _loadImage(
                                        alumnos[index].idalumno.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return const Icon(Icons.error);
                                      } else {
                                        final imageProvider = snapshot.data;
                                        final isDefaultImage =
                                            imageProvider is AssetImage;
                                        return Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 60,
                                              backgroundImage: imageProvider,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  isDefaultImage
                                                      ? textoImagen
                                                      : '',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    alumnos[index].nombre ??
                                        'Nombre no encontrado',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFE8F2FD),
                                      fontSize: 32,
                                      fontFamily: 'Open Sans Hebrew',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                              ]),
                        ),
                        onTap: () async {
                          context.read<AlumnoProvider>().clearInfo();
                          context
                              .read<AlumnoProvider>()
                              .getInfo(alumnos[index].idalumno ?? 0);
                          GoRouter.of(context).push('/home');
                        },
                      ),
                    );
                  }),
            ]),
    );
  }
}
