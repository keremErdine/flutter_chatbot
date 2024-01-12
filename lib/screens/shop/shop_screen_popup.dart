import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/screens/shop/buy_credits.dart';
import 'package:flutter_chatbot/screens/shop/upgrade_account.dart';

class ShopScreenPopup extends StatelessWidget {
  const ShopScreenPopup({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Daha fazla Hocam\$ alın.";
    Widget content = const BuyCredits();
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state.currentShopMenu == ShopMenu.levels) {
          title = "Hocam Bot seviyenizi yükseltin.";
          content = const UpgradeAccount();
        } else {
          title = "Daha fazla Hocam\$ alın.";
          content = const BuyCredits();
        }
      },
      builder: (context, state) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(0),
          title: Text(title),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AppBloc>()
                    .add(const AppShopMenuChanged(menu: ShopMenu.credits));
              },
              icon: const Icon(Icons.attach_money_outlined),
              label: Text(
                "Hocam\$ Al",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AppBloc>()
                    .add(const AppShopMenuChanged(menu: ShopMenu.levels));
              },
              icon: const Icon(Icons.leaderboard_rounded),
              label: Text(
                "Hocam Bot Seviyeni Yükselt",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )
          ],
          content: Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              final double width = MediaQuery.of(context).size.width;

              return SizedBox(
                height: height * 0.8,
                width: width * 0.8,
                child: content,
              );
            },
          ),
        );
      },
    );
  }
}
