import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Hocam Bot",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "explain",
          style: Theme.of(context).textTheme.bodyMedium,
        )
      ],
    );
  }
}
