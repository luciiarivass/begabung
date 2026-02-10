import 'package:flutter/material.dart';

class StarRatingChange extends StatefulWidget {
  final int rating;
  final int maxRating;
  final ValueChanged<int>? onRatingChanged;

  StarRatingChange(
      {required this.rating, this.maxRating = 5, this.onRatingChanged});

  @override
  _StarRatingChangeState createState() => _StarRatingChangeState();
}

class _StarRatingChangeState extends State<StarRatingChange> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return IconButton(
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 24.0,
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1;
            });
            if (widget.onRatingChanged != null) {
              widget.onRatingChanged!(_currentRating);
            }
          },
        );
      }),
    );
  }
}
