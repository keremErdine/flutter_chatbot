import 'package:flutter/material.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class UpgradeAccount extends StatelessWidget {
  const UpgradeAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class UpgradeAccountCard extends StatelessWidget {
  const UpgradeAccountCard(
      {super.key,
      required this.levelString,
      required this.color,
      required this.accountLevel,
      required this.description,
      required this.price,
      required this.features,
      required this.imagePath});
  final String levelString;
  final Color color;
  final String description;
  final double price;
  final AccountLevel accountLevel;
  final List<String> features;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final List<Widget> featuresList = [];
    for (var feature in features) {
      featuresList.add(Row(
        children: [
          SizedBox(
            width: width * 0.03,
          ),
          Text(feature),
        ],
      ));
      featuresList.add(SizedBox(
        height: height * 0.02,
      ));
    }

    return Card(
        child: SizedBox(
      width: width * 0.3,
      height: height * 0.75,
      child: Column(
        children: [
          Image.asset(imagePath),
          SizedBox(
            height: height * 0.01,
          ),
          Text(
            levelString,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(
            height: height * 0.04,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: height * 0.06,
          ),
          Column(
            children: featuresList,
          ),
          SizedBox(
            height: height * 0.03,
          )
        ],
      ),
    ));
  }
}
