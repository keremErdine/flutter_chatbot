import 'package:flutter/material.dart';

class GeneratingResponseIndicator extends StatelessWidget {
  const GeneratingResponseIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.timelapse_outlined),
        Text(
          "Cevap Oluşturuluyor...",
          style: Theme.of(context).textTheme.labelMedium,
        )
      ],
    );
  }
}
