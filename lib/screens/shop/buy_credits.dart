import 'package:flutter/material.dart';

enum CreditType { small, middle, big }

class BuyCredits extends StatelessWidget {
  const BuyCredits({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CreditPurchaseCard(
              creditType: CreditType.small,
              amount: 25000,
              color: Colors.blueAccent.shade100,
              description:
                  "Yaklaşık olarak 100 soru! Bu Hocam\$'lar size öğreniminize başlamanız için yetecek miktarda",
              price: 5),
          const SizedBox(
            height: 5,
          ),
          CreditPurchaseCard(
              creditType: CreditType.middle,
              amount: 250000,
              color: Colors.blueGrey.shade200,
              description:
                  "Yaklaşık olarak 1000 soru! Bu size yeter umarız ki.",
              price: 45),
          const SizedBox(
            height: 5,
          ),
          CreditPurchaseCard(
              creditType: CreditType.big,
              amount: 2500000,
              color: Colors.yellowAccent.shade100,
              description:
                  "Yaklaşık olarak 10000 soru! Bu kadara ne diye ihtiyacınız olsun ki?",
              price: 440),
        ],
      ),
    );
  }
}

class CreditPurchaseCard extends StatelessWidget {
  const CreditPurchaseCard(
      {super.key,
      required this.creditType,
      required this.amount,
      required this.color,
      required this.description,
      required this.price});
  final int amount;
  final Color color;
  final String description;
  final double price;
  final CreditType creditType;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          children: [
            const SizedBox(
              width: 5,
            ),
            Text(
              "$amount Hocam\$",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 10,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "$price ₺",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
