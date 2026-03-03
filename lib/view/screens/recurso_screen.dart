import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Recursos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 210,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Aún no hay recursos disponibles.\nAquí aparecerán cuando el profesor suba alguno.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
