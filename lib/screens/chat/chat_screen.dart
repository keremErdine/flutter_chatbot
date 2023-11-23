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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: GeneratingResponseIndicator()),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person),
                const SizedBox(
                  width: 10,
                ),
                Center(
                  child: Container(
                    width: 1000,
                    height: 22,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: "Hocam Bot'a soracağınız soruyu girin."),
                      maxLines: 1,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.titleMedium,
                      controller: controller,
                      onSubmitted: (message) {
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
                ),
                const SizedBox(
                  height: 15,
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
