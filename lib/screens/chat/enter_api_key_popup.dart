import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class EnterApiKeyPopup extends StatelessWidget {
  const EnterApiKeyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Column(
        children: [
          Text(
            "Bu uygulamayı kullanmak için bir OpenAI api anahtarı giriniz.",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(
            height: 7,
          ),
          Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 10,
              width: 60,
              child: TextFormField(
                controller: controller,
                autocorrect: false,
                enableSuggestions: false,
                onFieldSubmitted: (apiKey) {
                  context.read<AppBloc>().add(AppApiKeyEntered(apiKey: apiKey));
                },
              ))
        ],
      ),
    );
  }
}
