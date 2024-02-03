import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class UpgradeAccount extends StatelessWidget {
  const UpgradeAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const UpgradeAccountCard(
              levelString: "Ücretsiz",
              color: Colors.white70,
              accountLevel: AccountLevel.free,
              description: "Basit Hocam Bot deneyimi",
              price: 0,
              features: ["Hocam Bot'a erişim."],
              imagePath: "assets/account_level_icons/free.png"),
          UpgradeAccountCard(
              levelString: "Doçent",
              color: Colors.grey.shade200,
              accountLevel: AccountLevel.associate,
              description:
                  "Hocam Bot'a soru yazdırma özelliği ile tam istediğin konudan tam istediğin kadar soru yazdır!",
              price: 100,
              features: const [
                "Önceki seviyelerin özellikleri.",
                "Hocam Soru Bankası, yapay zekaya istediğiniz konudan soru yazdırın (ÇOK YAKINDA)"
              ],
              imagePath: "assets/account_level_icons/associate.png"),
          UpgradeAccountCard(
              levelString: "Profesör",
              color: Colors.yellowAccent.shade700,
              accountLevel: AccountLevel.professor,
              description:
                  "Maksimum Hocam Bot deneyimi! Her soruda %10 Hocam\$ indirimini hissedin veya Hocam Bot'u GPT-4 ile güçlendirin. ",
              price: 500,
              features: const [
                "Önceki seviyelerin özellikleri.",
                "Her soruda %10 Hocam\$ indirimi.",
                "GPT-4 güçlendirme özelliği. Bu özellik açıkken daha fazla Hocam\$ harcanır ama Hocam Bot daha zekice yanıtlar verir."
              ],
              imagePath: "assets/account_level_icons/proffesor.png")
        ],
      ),
    );
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
      featuresList.add(SizedBox(
        width: width * 0.3,
        child: Row(
          children: [
            SizedBox(
              width: width * 0.02,
            ),
            const Icon(Icons.list_outlined),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 50,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
      featuresList.add(SizedBox(
        height: height * 0.02,
      ));
    }
    Widget purchaseButton = ElevatedButton(
        onPressed: () {
          context
              .read<AppBloc>()
              .add(AppAccountLevelUpgraded(purchasedLevel: accountLevel));
        },
        child: Text(
          "$price ₺",
          style: Theme.of(context).textTheme.headlineMedium,
        ));

    if (AccountLevel.values.indexOf(accountLevel) <=
        AccountLevel.values
            .indexOf(context.read<AppBloc>().state.accountLevel)) {
      purchaseButton = ElevatedButton(
          onPressed: () {
            context
                .read<AppBloc>()
                .add(AppAccountLevelUpgraded(purchasedLevel: accountLevel));
          },
          child: Text(
            "$price ₺",
            style: Theme.of(context).textTheme.headlineMedium,
          ));
    }

    return Card(
        child: SizedBox(
      width: width * 0.25,
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
          const Spacer(),
          BlocConsumer<AppBloc, AppState>(
            listener: (context, state) {
              if (AccountLevel.values.indexOf(accountLevel) <=
                  AccountLevel.values.indexOf(state.accountLevel)) {
                purchaseButton = ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Zaten Sahipsin",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ));
              } else {
                purchaseButton = ElevatedButton(
                    onPressed: () {
                      context.read<AppBloc>().add(AppAccountLevelUpgraded(
                          purchasedLevel: accountLevel));
                    },
                    child: Text(
                      "$price ₺",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ));
              }
            },
            builder: (context, state) {
              return purchaseButton;
            },
          ),
          SizedBox(
            height: height * 0.03,
          )
        ],
      ),
    ));
  }
}
