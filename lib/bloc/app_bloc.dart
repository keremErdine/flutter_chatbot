// ignore_for_file: avoid_print, unused_local_variable

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot/classes/message.dart';
// ignore: unused_import
import 'package:flutter_chatbot/debug_tool.dart';
import 'package:flutter_chatbot/main.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:langchain/langchain.dart' as lang_chain;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';

part 'app_event.dart';
part 'app_state.dart';

late ChatOpenAI llm;
late OpenAIEmbeddings embeddings;
late Pinecone vectorStore;
late lang_chain.RetrievalQAChain qaChain;

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
    on<AppCreditsConsumed>(appCreditsConsumed);
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
    add(const AppMessageAddedToFirestore());
    if (event.message.sender == Sender.user) {
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
        if (state.credits <= 0) {
          add(AppMessageWritten(
              message: Message(
                  context:
                      "Hocam\$'ların bitti. Lütfen daha fazla Hocam\$ alınız.",
                  sender: Sender.system)));
          return;
        }
        String prompt =
            'You are a helpful teacher. You are in a conversation with one of your students.Respond only in Turkish. If you can\'t find the answer in the context, truthfully say that you couldn\'t find it. The conversation goes like this $conversation Student:${event.message.context} You:';
        Trace aiResponseTrace =
            FirebasePerformance.instance.newTrace('ai-response');
        await aiResponseTrace.start();
        final response = await qaChain.call(prompt);
        await aiResponseTrace.stop();
        add(AppMessageWritten(
            message: Message(
                context: _convertToUtf8(response['result']),
                sender: Sender.bot)));
        add(AppCreditsConsumed(text: prompt + response['result']));
      } catch (e) {
        add(AppMessageWritten(
            message: Message(
                context:
                    "Hocam Bot bir yanıt oluştururken bir hata oluştu. Oluşan hata: $e. Lütfen bu hatayı yapımcıya iletiniz.",
                sender: Sender.system)));
      }
      add(AppAIFinishedGeneratingResponse());
    }
  }

  String _convertToUtf8(String string) {
    print(string);
    string = string.replaceAll("Ä±", "ı");
    string = string.replaceAll("Ä°", "İ");
    string = string.replaceAll("Ã¶", "ö");
    string = string.replaceAll("Å", "ş");
    string = string.replaceAll("Ã", "Ö");
    string = string.replaceAll("Ã¼", "ü");
    string = string.replaceAll("Ä", "ğ");
    string = string.replaceAll("Ã§", "ç");
    string = string.replaceAll("â", "'");
    string = string.replaceAll("Ã¢", "a");
    string = string.replaceAll("Å", "Ş");
    return string;
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
    if (email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
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
    print("Done reading prefs");
    //addVectorsToStore();
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
      add(AppMessageWritten(
          message: Message(
              context:
                  "Bir hata oluştu: $e. Lütfen bu hatayı yapımcıya iletin.",
              sender: Sender.system)));
    }
  }

  void appApiKeyEntered(AppApiKeyEntered event, Emitter emit) async {
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
        apiKey: openAiApiKey,
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
        return;
      } else if (e.code == 'invalid-login-credentials') {
        add(AppMessageWritten(
            message: Message(
                context: "Bu parola bu kullanıcı için yanlış. Yine deneyiniz.",
                sender: Sender.system)));
        return;
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
        emit(state.copyWith(screen: Screen.welcomeScreen));
        return;
      }
    } catch (e) {
      add(AppMessageWritten(
          message: Message(
              context: "Başka bir hata oluştu. Yine deneyiniz.",
              sender: Sender.system)));
      emit(state.copyWith(screen: Screen.welcomeScreen));
      return;
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
      "temperature": "normal",
      "credits": 5000
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
    final int tokensLeft = await userData.get("credits");

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

    emit(state.copyWith(
        messages: decodedMessages, userName: userName, credits: tokensLeft));
  }

  void appAccountMenuPageChanged(
      AppAccountMenuPageChanged event, Emitter emit) {
    emit(state.copyWith(currentAcountMenu: event.accountMenu));
  }

  void appUserLoggedOut(AppUserLoggedOut event, Emitter emit) async {
    emit(state.copyWith(
        messages: <Message>[],
        temperature: Temperature.normal,
        loggedIn: false,
        credential: null,
        userName: "",
        currentAcountMenu: AccountMenu.login));
    add(AppMessageWritten(
        message:
            Message(context: "Hesabından çıktın.", sender: Sender.system)));
    SharedPreferences prefs = await state.prefs;
    await prefs.setString("email", "");
    await prefs.setString("password", "");
  }

  void appCreditsConsumed(AppCreditsConsumed event, Emitter emit) async {
    final int creditCost = event.text.length ~/ 3;
    emit(state.copyWith(credits: state.credits - creditCost));
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    await users
        .doc(state.credential!.user!.uid)
        .set({"credits": state.credits}, SetOptions(merge: true));
  }
}
