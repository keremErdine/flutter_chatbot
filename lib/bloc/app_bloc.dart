import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot/api_key.dart';
import 'package:flutter_chatbot/classes/message.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:langchain/langchain.dart' as lang_chain;

part 'app_event.dart';
part 'app_state.dart';

final OpenAI llm = OpenAI(apiKey: openAIapiKey);
final embeddings = OpenAIEmbeddings(apiKey: openAIapiKey);
final vectorStore = Pinecone(
    apiKey: pineconeApiKey, indexName: indexName, embeddings: embeddings);
final lang_chain.RetrievalQAChain qaChain = lang_chain.RetrievalQAChain.fromLlm(
  llm: llm,
  retriever: vectorStore.asRetriever(),
);

const textSplitter = lang_chain.RecursiveCharacterTextSplitter(
  chunkSize: 1000,
  chunkOverlap: 200,
);

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<AppDocumentAdded>(appDocumentAdded);
    on<AppMessageWritten>(appMessageWritten);
    on<AppAIStartedGeneratingResponse>(appAIStartedGeneratingResponse);
    on<AppAIFinishedGeneratingResponse>(appAIFinishedGeneratingResponse);
    on<AppScreenChanged>(appScreenChanged);
  }

  void appDocumentAdded(AppDocumentAdded event, Emitter emit) async {
    final lang_chain.TextLoader loader =
        lang_chain.TextLoader(event.document.path);
    final docs = await loader.load();
    final splittedDocs = textSplitter.splitDocuments(docs);

    vectorStore.addDocuments(documents: splittedDocs);
  }

  void appMessageWritten(AppMessageWritten event, Emitter emit) async {
    emit(state.addMessage(event.message));
    if (event.message.sender == Sender.user) {
      add(AppAIStartedGeneratingResponse());
      final response = await qaChain.call(
          '${event.message.context} Respond only in Turkish. If you can\'t find the answer in the documents, truthfully say that you couldn\'t find it.');
      add(AppAIFinishedGeneratingResponse());
      add(AppMessageWritten(
          message: Message(context: response['result'], sender: Sender.bot)));
    }
  }

  void appAIStartedGeneratingResponse(
      AppAIStartedGeneratingResponse event, Emitter emit) {
    emit(state.copyWith(generatingResponse: true));
  }

  void appAIFinishedGeneratingResponse(
      AppAIFinishedGeneratingResponse event, Emitter emit) {
    emit(state.copyWith(generatingResponse: false));
  }

  void appScreenChanged(AppScreenChanged event, Emitter emit) {
    emit(state.copyWith(screen: event.screen));
  }
}
