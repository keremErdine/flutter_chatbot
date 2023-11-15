import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/classes/message.dart' as message_app;
import 'package:flutter_chatbot/classes/message.dart';
import 'package:flutter_chatbot/widgets/generating_response_widget.dart';
import 'package:flutter_chatbot/widgets/message_widget.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    ScrollController scrollController = ScrollController();

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            Messages(
              messages: state.messages,
              controller: scrollController,
            ),
            if (state.generatingResponse)
              const Row(
                children: [
                  Center(child: GeneratingResponseIndicator()),
                ],
              ),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 50,
                  width: 1000,
                  child: TextFormField(
                    style: Theme.of(context).textTheme.titleMedium,
                    controller: controller,
                    onFieldSubmitted: (message) {
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                      controller.clear();
                      context.read<AppBloc>().add(AppMessageWritten(
                              message: message_app.Message(
                            context: message,
                            sender: Sender.user,
                          )));
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class Messages extends StatelessWidget {
  const Messages({super.key, required this.messages, required this.controller});
  final List<message_app.Message> messages;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var message in messages) {
      widgets.add(MessageWidget(
        message: message,
      ));
      widgets.add(const SizedBox(
        height: 3,
      ));
    }
    return Expanded(
      child: ListView(
        controller: controller,
        children: widgets,
      ),
    );
  }
}
