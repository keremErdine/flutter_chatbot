import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class EnterApiKeyPopup extends StatelessWidget {
  const EnterApiKeyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Text(
                  "Bu uygulamayı kullanmak için bir OpenAI api anahtarı giriniz.",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all()),
                height: 25,
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: controller,
                  autocorrect: false,
                  enableSuggestions: false,
                  onFieldSubmitted: (apiKey) {
                    context
                        .read<AppBloc>()
                        .add(AppApiKeyEntered(apiKey: apiKey));
                  },
                ),
              ),
              const SizedBox(
                height: 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}
