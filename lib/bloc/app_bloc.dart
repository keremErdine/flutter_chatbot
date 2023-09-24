import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_chatbot/api_key.dart';
import 'package:flutter_chatbot/classes/message.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain/langchain.dart' as lang_chain;

part 'app_event.dart';
part 'app_state.dart';

final OpenAI llm = OpenAI(apiKey: apiKey);
final lang_chain.ConversationChain conversation =
    lang_chain.ConversationChain(llm: llm);

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<AppDocumentAdded>(appDocumentAdded);
    on<AppMessageWritten>(appMessageWritten);
  }

  void appDocumentAdded(AppDocumentAdded event, Emitter emit) {
    final List<String> list = state.filePaths;
    list.add(event.document.path);
    emit(state.copyWith(filePaths: list));
  }

  void appMessageWritten(AppMessageWritten event, Emitter emit) async {
    emit(state.addMessage(event.message));
    if (event.message.sender == Sender.user) {
      add(AppMessageWritten(
          message: Message(
              message: await conversation.run(
                '${event.message.message}. Respond in Turkish.',
              ),
              sender: Sender.bot)));
    }
  }
}
