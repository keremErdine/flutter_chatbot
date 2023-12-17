import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class LogoutPopup extends StatelessWidget {
  const LogoutPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AppBloc>().add(const AppUserLoggedOut());
            },
            icon: const Icon(Icons.exit_to_app_outlined),
            label: Text("Çıkış Yap",
                style: Theme.of(context).textTheme.headlineSmall))
      ],
      title: Text(
        "Çıkış Yap",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Center(
        child: Text(
          "Çıkış yapmak istediğine emin misin?",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
