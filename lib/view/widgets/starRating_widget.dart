import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;

  StarRating({required this.rating, this.maxRating = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24.0,
        );
      }),
    );
  }
}
