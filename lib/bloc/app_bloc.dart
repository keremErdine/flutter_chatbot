// ignore_for_file: avoid_print, unused_local_variable

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

ChatOpenAI llm =
    ChatOpenAI(apiKey: "", model: "gpt-3.5-turbo-1106", temperature: 0.25);
OpenAIEmbeddings embeddings = OpenAIEmbeddings(apiKey: "");
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
    on<AppMessageWritten>(appMessageWritten);
    on<AppAIStartedGeneratingResponse>(appAIStartedGeneratingResponse);
    on<AppAIFinishedGeneratingResponse>(appAIFinishedGeneratingResponse);
    on<AppScreenChanged>(appScreenChanged);
    on<AppChatHistoryCleared>(appChatHistoryCleared);
    on<AppDataFromPrefsRead>(appDataFromPrefsRead);
    on<AppMessageAddedToFirestore>(appMessageAddedToFirestore);
    on<AppApiKeyEntered>(appApiKeyEntered);
    on<AppAITemperatureSelected>(appAITemperatureSelected);
    on<AppUserLoggedIn>(appUserLoggedIn);
    on<AppUserSignedUp>(appUserSignedUp);
    on<AppAccountMenuPageChanged>(appAccountMenuPageChanged);
    on<AppFirebaseDataRead>(appFirebaseDataRead);
    on<AppUserLoggedOut>(appUserLoggedOut);
  }

  void appMessageWritten(AppMessageWritten event, Emitter emit) async {
    emit(state.addMessage(event.message));
    if (state.loggedIn == false && event.message.sender != Sender.system) {
      add(AppMessageWritten(
          message: Message(
              context:
                  "Giriş yapmadığınız için bu uygulamayı kullanamazsınız. Lütfen giriş yapın.",
              sender: Sender.system)));
      return;
    }
    add(AppMessageAddedToFirestore());
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
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final String uid = state.credential!.user!.uid;
    users.doc(uid).set({"messages": <String>[], "messageSenders": <String>[]},
        SetOptions(merge: true));
  }

  void appDataFromPrefsRead(AppDataFromPrefsRead event, Emitter emit) async {
    final SharedPreferences prefs = await state.prefs;

    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    if (email != null && password != null) {
      add(AppUserLoggedIn(email: email, password: password));
    }

    Screen screen = Screen.loadingScreen;
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
    emit(state.copyWith(
      screen: screen,
    ));
  }

  void appMessageAddedToFirestore(
      AppMessageAddedToFirestore event, Emitter emit) async {
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection("Users");
      final String uid = state.credential!.user!.uid;
      final List<String> messages = [];
      final List<String> senders = [];
      for (var message in state.messages) {
        if (message.sender != Sender.system) {
          messages.add(message.context);
          switch (message.sender) {
            case Sender.user:
              senders.add("user");
              break;
            default:
              senders.add("bot");
          }
        }
      }
      users.doc(uid).set({"messages": messages, "messageSenders": senders},
          SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  void appApiKeyEntered(AppApiKeyEntered event, Emitter emit) async {
    llm = ChatOpenAI(apiKey: event.apiKey, model: "gpt-3.5-turbo-1106");
    embeddings = OpenAIEmbeddings(apiKey: event.apiKey);
    emit(state.copyWith(apiKey: event.apiKey));
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final String uid = state.credential!.user!.uid;
    await users.doc(uid).set({"apiKey": event.apiKey}, SetOptions(merge: true));
  }

  void appAITemperatureSelected(
      AppAITemperatureSelected event, Emitter emit) async {
    if (state.loggedIn == false) {
      return;
    }
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
    String temperatureValue = "normal";
    if (event.temperature == Temperature.direct) {
      temperatureValue = "direct";
    } else if (event.temperature == Temperature.normal) {
      temperatureValue = "normal";
    } else if (event.temperature == Temperature.high) {
      temperatureValue = "high";
    } else if (event.temperature == Temperature.extreme) {
      temperatureValue = "extreme";
    } else if (event.temperature == Temperature.overkill) {
      temperatureValue = "overkill";
    }

    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    await users
        .doc(state.credential!.user!.uid)
        .set({"temperature": temperatureValue}, SetOptions(merge: true));
  }

  void appUserLoggedIn(AppUserLoggedIn event, Emitter emit) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: event.email, password: event.password)
          .then((value) async {
        emit(state.copyWith(credential: value, loggedIn: true));
        add(AppFirebaseDataRead());
        final SharedPreferences prefs = await state.prefs;
        prefs.setString("email", event.email);
        prefs.setString("password", event.password);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        add(AppMessageWritten(
            message: Message(
                context:
                    "Bu e-postayı kullanan bir kullanıcı bulunamadı. Hesap mı açmak istemiştiniz?",
                sender: Sender.system)));
      } else if (e.code == 'invalid-login-credentials') {
        add(AppMessageWritten(
            message: Message(
                context: "Bu parola bu kullanıcı için yanlış. Yine deneyiniz.",
                sender: Sender.system)));
      } else {
        add(AppMessageWritten(
            message: Message(context: e.code, sender: Sender.system)));
      }
    }
  }

  void appUserSignedUp(AppUserSignedUp event, Emitter emit) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      _userSetup(uid: credential.user!.uid, userName: event.userName);
      final SharedPreferences prefs = await state.prefs;
      prefs.setString("email", event.email);
      prefs.setString("password", event.password);
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
    add(AppFirebaseDataRead());
  }

  void _userSetup({required String uid, required String userName}) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    await users.doc(uid).set({
      "uid": uid,
      "userName": userName,
      "messages": state.messages.map(
        (message) => message.context,
      ),
      "apiKey": "",
      "messageSenders": state.messages.map(
        (message) {
          if (message.sender == Sender.bot) {
            return "bot";
          } else if (message.sender == Sender.user) {
            return "user";
          } else if (message.sender == Sender.system) {
            return "system";
          }
        },
      ),
      "temperature": "normal"
    }).then((value) {
      print("New user sucesfully created");
    });
  }

  void appFirebaseDataRead(AppFirebaseDataRead event, Emitter emit) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    final DocumentSnapshot userData =
        await users.doc(state.credential!.user!.uid).get();
    final String userName = await userData.get("userName") as String;
    final List messages = await userData.get("messages") as List<dynamic>;

    final List senders = await userData.get("messageSenders") as List<dynamic>;
    final List<Message> decodedMessages = <Message>[];
    final String apiKey = await userData.get("apiKey") as String;

    if (messages != []) {
      for (var message in messages) {
        Sender decodedSender = Sender.system;
        if (senders[messages.indexOf(message)] == "bot") {
          decodedSender = Sender.bot;
        } else if (senders[messages.indexOf(message)] == "user") {
          decodedSender = Sender.user;
        }
        decodedMessages.add(Message(
          context: message,
          sender: decodedSender,
        ));
      }
    }

    final String temperatureValue = await userData.get("temperature") as String;
    double temperature = 0.25;
    switch (temperatureValue) {
      case "direct":
        temperature = 0;
        break;
      case "high":
        temperature = 0.5;
        break;
      case "extreme":
        temperature = 0.75;
        break;
      case "overkill":
        temperature = 1;
        break;
      default:
        temperature = 0.25;
    }

    if (apiKey.isNotEmpty) {
      llm = ChatOpenAI(
          apiKey: apiKey,
          model: "gpt-3.5-turbo-1106",
          temperature: temperature);
      embeddings = OpenAIEmbeddings(apiKey: apiKey);
    }

    emit(state.copyWith(
        messages: decodedMessages, apiKey: apiKey, userName: userName));
  }

  void appAccountMenuPageChanged(
      AppAccountMenuPageChanged event, Emitter emit) {
    emit(state.copyWith(currentAcountMenu: event.accountMenu));
  }

  void appUserLoggedOut(AppUserLoggedOut event, Emitter emit) {
    emit(state.copyWith(
        messages: <Message>[],
        apiKey: "",
        temperature: Temperature.normal,
        loggedIn: false,
        credential: null,
        userName: "",
        currentAcountMenu: AccountMenu.login));
    add(AppMessageWritten(
        message:
            Message(context: "Hesabından çıktın.", sender: Sender.system)));
  }
}
