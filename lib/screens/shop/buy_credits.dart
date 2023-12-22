import 'package:flutter/material.dart';

class BuyCredits extends StatelessWidget {
  const BuyCredits({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          CreditPurchaseCard(
              amount: 25000,
              color: Colors.blueAccent.shade100,
              description:
                  "Yaklaşık olarak 100 soru! Bu Hocam\$'lar size öğreniminize başlamanız için yetecek miktarda",
              price: 5),
          const SizedBox(
            width: 5,
          ),
          CreditPurchaseCard(
              amount: 250000,
              color: Colors.blueGrey.shade200,
              description:
                  "Yaklaşık olarak 1000 soru! Bu size yeter umarız ki.",
              price: 45),
          const SizedBox(
            width: 5,
          ),
          CreditPurchaseCard(
              amount: 2500000,
              color: Colors.yellowAccent.shade100,
              description:
                  "Yaklaşık olarak 10000 soru! Bu kadara ne diye ihtiyacınız olsun ki?",
              price: 440)
        ],
      ),
    );
  }
}

class CreditPurchaseCard extends StatelessWidget {
  const CreditPurchaseCard(
      {super.key,
      required this.amount,
      required this.color,
      required this.description,
      required this.price});
  final int amount;
  final Color color;
  final String description;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Column(
        children: [
          const SizedBox(
            height: 3,
          ),
          Text(
            "$amount Hocam\$",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {},
              child: Text(
                "$price ₺",
                style: Theme.of(context).textTheme.headlineSmall,
              ))
        ],
      ),
    );
  }
}
