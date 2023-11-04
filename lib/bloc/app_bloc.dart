import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
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
  }

  void appDocumentAdded(AppDocumentAdded event, Emitter emit) async {
    final lang_chain.TextLoader loader =
        lang_chain.TextLoader(event.document.path);
    final docs = await loader.load();
    final splittedDocs = textSplitter.splitDocuments(docs);
    print("Splitted ${splittedDocs.length} chunks.");
    vectorStore.addDocuments(documents: splittedDocs);
  }

  void appMessageWritten(AppMessageWritten event, Emitter emit) async {
    emit(state.addMessage(event.message));
    if (event.message.sender == Sender.user) {
      add(AppMessageWritten(
          message: Message(
              context: await qaChain
                  .call(
                    event.message.context,
                  )
                  .then((value) => value["result"]),
              sender: Sender.bot)));
    }
  }
}
