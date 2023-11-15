import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return ListView(
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy_outlined),
                Text(
                  "Hocam Bot",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left,
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            //Sohbet Ekranı
            if (state.screen == Screen.chatScreen)
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  const Icon(Icons.smart_toy_outlined),
                  Text(
                    "Sohbet",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            else
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<AppBloc>()
                          .add(AppScreenChanged(screen: Screen.chatScreen));
                    },
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: Text(
                      "Sohbet",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            const SizedBox(
              height: 5,
            ),
            //Hakkında Ekranı
            if (state.screen == Screen.aboutScreen)
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  const Icon(Icons.menu_book_outlined),
                  Text(
                    "Hakkında",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            else
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<AppBloc>()
                          .add(AppScreenChanged(screen: Screen.aboutScreen));
                    },
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(
                      "Hakkında",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Spacer(),
                ],
              )
          ],
        );
      },
    ));
  }
}
