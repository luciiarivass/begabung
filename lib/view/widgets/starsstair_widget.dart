// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class StarstairWidget extends StatelessWidget {
  final List<String> textos;
  const StarstairWidget(this.textos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(height: 6),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
      ]),
      const Text(
        "Primeros pasos",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        textos[0],
        textAlign: TextAlign.center,
      ),
      const Divider(
        color: Colors.grey,
        thickness: 1,
        height: 40,
        indent: 80,
        endIndent: 80,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
      ]),
      const Text(
        "En marcha",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        textos[1],
        textAlign: TextAlign.center,
      ),
      const Divider(
        color: Colors.grey,
        thickness: 1,
        height: 40,
        indent: 80,
        endIndent: 80,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
      ]),
      const Text(
        "Progresando",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        textos[2],
        textAlign: TextAlign.center,
      ),
      const Divider(
        color: Colors.grey,
        thickness: 1,
        height: 40,
        indent: 80,
        endIndent: 80,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star_border_outlined,
          color: Colors.amber,
          size: 24.0,
        ),
      ]),
      const Text(
        "Brillando",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        textos[3],
        textAlign: TextAlign.center,
      ),
      const Divider(
        color: Colors.grey,
        thickness: 1,
        height: 40,
        indent: 80,
        endIndent: 80,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 24.0,
        ),
      ]),
      const Text(
        "Inspirando",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        textos[4],
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
