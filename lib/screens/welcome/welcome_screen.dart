import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Text(
                "Hocam Bot",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "Öğretici yapay zeka uygulaması",
                style: Theme.of(context).textTheme.displaySmall,
              )
            ],
          ),
        )
      ],
    );
  }
}
