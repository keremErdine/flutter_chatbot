import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/screens/account_popup/account_popup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AccountMenuPopup(),
                );
                context
                    .read<AppBloc>()
                    .add(const AppScreenChanged(screen: Screen.chatScreen));
              },
              child: Text(
                "Şimdi Başla",
                style: Theme.of(context).textTheme.headlineLarge,
              )),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
