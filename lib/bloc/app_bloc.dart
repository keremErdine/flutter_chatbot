// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot/api_key.dart';
import 'package:flutter_chatbot/classes/message.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:langchain/langchain.dart' as lang_chain;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'app_event.dart';
part 'app_state.dart';

ChatOpenAI llm = ChatOpenAI(
    apiKey: openAIapiKey, model: "gpt-3.5-turbo-1106", temperature: 0.25);
OpenAIEmbeddings embeddings = OpenAIEmbeddings(apiKey: openAIapiKey);
final Pinecone vectorStore = Pinecone(
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
    on<AppChatHistoryCleared>(appChatHistoryCleared);
    on<AppDataFromPrefsRead>(appDataFromPrefsRead);
    on<AppMessageAddedToPrefs>(appMessageAddedToPrefs);
    on<AppApiKeyEntered>(appApiKeyEntered);
    on<AppAITemperatureSelected>(appAITemperatureSelected);
    on<AppUserLoggedIn>(appUserLoggedIn);
    on<AppUserSignedUp>(appUserSignedUp);
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
    add(AppMessageAddedToPrefs());
    if (state.apiKey.isEmpty && event.message.sender != Sender.system) {
      add(AppMessageWritten(
          message: Message(
              context:
                  "Bir OpenAI api anahtarı girmediğinizden dolayı uygulamayı kullanamazsınız. Lütfen bir OpenAI api anahtarı girip tekrar deneyiniz.",
              sender: Sender.system)));
    } else if (event.message.sender == Sender.user) {
      add(AppAIStartedGeneratingResponse());
      String conversation = "";
      for (var message in state.messages) {
        if (message.sender == Sender.user) {
          conversation = "$conversation\nStudent:${message.context}";
        } else if (message.sender == Sender.bot) {
          conversation = "$conversation\nYou:${message.context}";
        }
      }
      try {
        final response = await qaChain.call(
            'You are a helpful teacher. You are in a conversation with one of your students.Respond only in Turkish. If you can\'t find the answer in the documents, truthfully say that you couldn\'t find it. The conversation goes like this:  Student: ${event.message.context}\n You: ');

        add(AppMessageWritten(
            message: Message(context: response['result'], sender: Sender.bot)));
      } catch (e) {
        add(AppMessageWritten(
            message: Message(
                context:
                    "Hocam Bot bir yanıt oluştururken bir hata oluştu. Bu doğru bir OpenAI api anahtarı girmediğinizden kaynaklanıyor olabilir.",
                sender: Sender.system)));
      }
      add(AppAIFinishedGeneratingResponse());
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

  void appScreenChanged(AppScreenChanged event, Emitter emit) async {
    final SharedPreferences prefs = await state.prefs;

    emit(state.copyWith(screen: event.screen));
    if (event.screen == Screen.welcomeScreen) {
      await prefs.setString("screen", "welcome");
    } else if (event.screen == Screen.aboutScreen) {
      await prefs.setString("screen", "about");
    } else if (event.screen == Screen.chatScreen) {
      await prefs.setString("screen", "chat");
    }
  }

  void appChatHistoryCleared(AppChatHistoryCleared event, Emitter emit) async {
    emit(state.copyWith(messages: []));
    final SharedPreferences prefs = await state.prefs;
    await prefs.setStringList("messages", <String>[]);
    await prefs.setStringList("message_senders", <String>[]);
  }

  void appDataFromPrefsRead(AppDataFromPrefsRead event, Emitter emit) async {
    final SharedPreferences prefs = await state.prefs;
    Screen screen = Screen.loadingScreen;
    List<String>? messages = prefs.getStringList("messages");
    List<String>? senders = prefs.getStringList("message_senders");
    List<Message> decodedMessages = <Message>[];

    if (messages == null) {
      await prefs.setStringList("messages", [
        "Aşağıdaki kutucuğa yazı yazarak soru sorunuz. Hocam Bot(Yapay Zeka) sorunu yanıtlamaya çalışacaktır."
      ]);
      await prefs.setStringList("message_senders", ["system"]);
    } else {
      for (var message in messages) {
        Sender decodedSender = Sender.system;
        if (senders![messages.indexOf(message)] == "bot") {
          decodedSender = Sender.bot;
        } else if (senders[messages.indexOf(message)] == "user") {
          decodedSender = Sender.user;
        }
        decodedMessages.add(Message(context: message, sender: decodedSender));
      }
    }

    switch (prefs.getString("screen")) {
      case "chat":
        screen = Screen.chatScreen;
        break;
      case "about":
        screen = Screen.aboutScreen;
        break;
      default:
        screen = Screen.welcomeScreen;
        await prefs.setString("screen", "welcome");
    }

    int temperatureValue = prefs.getInt("ai_temperature") ?? 0;
    Temperature temperatureEnum = Temperature.normal;
    double aiTemperature = 0.25;
    switch (temperatureValue) {
      case 1:
        aiTemperature = 0;
        temperatureEnum = Temperature.direct;
        break;
      case 2:
        aiTemperature = 0.25;
        temperatureEnum = Temperature.normal;
        break;
      case 3:
        aiTemperature = 0.5;
        temperatureEnum = Temperature.high;
        break;
      case 4:
        aiTemperature = 0.75;
        temperatureEnum = Temperature.extreme;
        break;
      case 5:
        aiTemperature = 1;
        temperatureEnum = Temperature.overkill;
        break;
      default:
        await prefs.setInt("ai_temperature", 2);
    }

    String apiKey = prefs.getString("user_api_key") ?? "";
    if (apiKey.isNotEmpty) {
      llm = ChatOpenAI(
          apiKey: apiKey,
          model: "gpt-3.5-turbo-1106",
          temperature: aiTemperature);
      embeddings = OpenAIEmbeddings(apiKey: apiKey);
    }

    emit(state.copyWith(
        screen: screen,
        messages: decodedMessages,
        apiKey: apiKey,
        temperature: temperatureEnum));
  }

  void appMessageAddedToPrefs(
      AppMessageAddedToPrefs event, Emitter emit) async {
    final SharedPreferences prefs = await state.prefs;
    final List<String> messages = [];
    final List<String> senders = [];
    for (var message in state.messages) {
      messages.add(message.context);
      switch (message.sender) {
        case Sender.user:
          senders.add("user");
          break;
        case Sender.bot:
          senders.add("bot");
          break;
        default:
          senders.add("system");
      }
    }
    await prefs.setStringList("messages", messages);
    await prefs.setStringList("message_senders", senders);
  }

  void appApiKeyEntered(AppApiKeyEntered event, Emitter emit) async {
    llm = ChatOpenAI(apiKey: event.apiKey, model: "gpt-3.5-turbo-1106");
    embeddings = OpenAIEmbeddings(apiKey: event.apiKey);
    emit(state.copyWith(apiKey: event.apiKey));
    SharedPreferences prefs = await state.prefs;
    await prefs.setString("user_api_key", event.apiKey);
  }

  void appAITemperatureSelected(
      AppAITemperatureSelected event, Emitter emit) async {
    double temperature = 0.25;
    if (event.temperature == Temperature.direct) {
      temperature = 0;
    } else if (event.temperature == Temperature.normal) {
      temperature = 0.25;
    } else if (event.temperature == Temperature.high) {
      temperature = 0.5;
    } else if (event.temperature == Temperature.extreme) {
      temperature = 0.75;
    } else if (event.temperature == Temperature.overkill) {
      temperature = 1;
    } else {
      add(AppMessageWritten(
          message: Message(
              context:
                  "Hocam Bot karmaşıklığı seçilirken bir hata oluştuğundan normal seviyesine ayarlandı.",
              sender: Sender.system)));
    }

    llm = ChatOpenAI(
        apiKey: state.apiKey,
        model: "gpt-3.5-turbo-1106",
        temperature: temperature);
    emit(state.copyWith(temperature: event.temperature));
    final SharedPreferences prefs = await state.prefs;
    int temperatureValue = 2;
    if (event.temperature == Temperature.direct) {
      temperatureValue = 1;
    } else if (event.temperature == Temperature.normal) {
      temperatureValue = 2;
    } else if (event.temperature == Temperature.high) {
      temperatureValue = 3;
    } else if (event.temperature == Temperature.extreme) {
      temperatureValue = 4;
    } else if (event.temperature == Temperature.overkill) {
      temperatureValue = 5;
    }

    await prefs.setInt("ai_temperature", temperatureValue);
  }

  void appUserLoggedIn(AppUserLoggedIn event, Emitter emit) {}
  void appUserSignedUp(AppUserSignedUp event, Emitter emit) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        add(AppMessageWritten(
            message: Message(
                context: "Girdiğiniz parola çok zayıf. Yine deneyiniz.",
                sender: Sender.system)));
      } else if (e.code == 'email-already-in-use') {
        add(AppMessageWritten(
            message: Message(
                context:
                    "Girdiğiniz e-posta zaten kullanılıyor. Yine deneyiniz.",
                sender: Sender.system)));
      }
    } catch (e) {
      add(AppMessageWritten(
          message: Message(
              context: "Başka bir hata oluştu. Yine deneyiniz.",
              sender: Sender.system)));
      print(e);
    }

    emit(state.copyWith(credential: credential));
  }
}
