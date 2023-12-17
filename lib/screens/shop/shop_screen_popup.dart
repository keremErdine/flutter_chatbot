import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class ShopScreenPopup extends StatelessWidget {
  const ShopScreenPopup({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Daha fazla Hocam\$ alın.";
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state.currentShopMenu == ShopMenu.levels) {
          title = "Hocam Bot seviyenizi yükseltin.";
        } else {
          title = "Daha fazla Hocam\$ alın.";
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: Text(title),
        );
      },
    );
  }
}
