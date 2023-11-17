import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class EnterAPIKeyPopup extends StatelessWidget {
  const EnterAPIKeyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Text(
          "Daha API anahtarı girmedin!",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          child: TextFormField(
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            onFieldSubmitted: (value) {
              context.read<AppBloc>().add(AppUserAPIKeyEntered(apiKey: value));
            },
          ),
        ),
        const SizedBox(
          height: 1.5,
        ),
        ElevatedButton(
            onPressed: () {
              context
                  .read<AppBloc>()
                  .add(AppUserAPIKeyEntered(apiKey: controller.value.text));
            },
            child: Center(
              child: Text(
                "TAMAM",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ))
      ],
    );
  }
}
