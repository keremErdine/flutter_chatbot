import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/classes/message.dart' as message_app;
import 'package:flutter_chatbot/classes/message.dart';
import 'package:flutter_chatbot/widgets/message_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    ScrollController scrollController = ScrollController();

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Container(
              color: Colors.lightBlueAccent,
              child: Column(
                children: [
                  Text(
                    'Bir dosya ekle.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropTarget(
                      onDragDone: (details) {
                        context
                            .read<AppBloc>()
                            .add(AppDocumentAdded(document: details.files[0]));
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.blueAccent,
                        child: Center(
                          child: Text(
                            'Belgelerini buraya koy!',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return Expanded(
                child: Column(
                  children: [
                    Messages(
                      messages: state.messages,
                      controller: scrollController,
                    ),
                    SizedBox(
                      height: 50,
                      width: 1000,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.titleMedium,
                        controller: controller,
                        onFieldSubmitted: (message) {
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                          controller.clear();
                          context.read<AppBloc>().add(AppMessageWritten(
                                  message: message_app.Message(
                                message: message,
                                sender: Sender.user,
                              )));
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
