import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final String left;
  final String right;

  const StatsWidget(this.left, this.right, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(left), Text(right)],
        ),
      );
}
