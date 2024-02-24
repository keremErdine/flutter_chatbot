// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot/classes/message.dart';
// ignore: unused_import
import 'package:flutter_chatbot/debug_tool.dart';
import 'package:flutter_chatbot/main.dart';

import 'package:flutter_chatbot/screens/shop/buy_credits.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:langchain/langchain.dart' as lang_chain;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:uuid/uuid.dart';

part 'app_event.dart';
part 'app_state.dart';

late ChatOpenAI llm;
late OpenAIEmbeddings embeddings;
late Pinecone vectorStore;
late lang_chain.RetrievalQAChain qaChain;
const Uuid uuid = Uuid();

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
    on<AppShopMenuChanged>(appShopMenuChanged);
    on<AppCreditsPurchased>(appCreditsPurchased);
    on<AppAccountLevelUpgraded>(appAccountLevelUpgraded);
    on<AppErrorOccured>(appErrorOccured);
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
      add(const AppAIStartedGeneratingResponse());
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
                      "Biljet'iniz bitti. Lütfen daha fazla Biljet alınız.",
                  sender: Sender.system)));
          add(const AppAIFinishedGeneratingResponse());
          return;
        }
        String aiPrompt =
            '$prompt The conversation goes like this: $conversation Student:${event.message.context} You: ';
        Trace aiResponseTrace =
            FirebasePerformance.instance.newTrace('ai-response');
        await aiResponseTrace.start();
        final response = await qaChain.call(aiPrompt);
        await aiResponseTrace.stop();
        add(AppMessageWritten(
            message: Message(
                context: _convertToUtf8(response['result']),
                sender: Sender.bot)));
        add(AppCreditsConsumed(text: aiPrompt + response['result']));
      } catch (e) {
        add(AppMessageWritten(
            message: Message(
                context:
                    "Hocam Bot bir yanıt oluştururken bir hata oluştu. Oluşan hata: $e. Lütfen bu hatayı yapımcıya iletiniz.",
                sender: Sender.system)));
        add(AppErrorOccured(details: e.toString()));
      }
      add(const AppAIFinishedGeneratingResponse());
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
    string = string.replaceAll("Ã", "Ç");
    string = string.replaceAll("Ã", "Ü");
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
    try {
      final SharedPreferences prefs = await state.prefs;

      String? email = prefs.getString("email");
      String? password = prefs.getString("password");
      if (email != null &&
          password != null &&
          email.isNotEmpty &&
          password.isNotEmpty) {
        // add(AppUserLoggedIn(email: email, password: password));
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
      addVectorsToStore();
    } catch (e) {
      add(AppErrorOccured(details: e.toString()));
    }
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
      add(AppErrorOccured(details: e.toString()));
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
    /*if (state.loggedIn == false) {
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
        apiKey: openAiApiKey,);
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
        .set({"temperature": temperatureValue}, SetOptions(merge: true));*/
  }

  void appUserLoggedIn(AppUserLoggedIn event, Emitter emit) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: event.email, password: event.password)
          .then((credential) {
        print(credential);
        add(AppFirebaseDataRead(credential: credential));
      });
      add(AppMessageWritten(
          message: Message(
              context: "Hesabınıza giriş yapılmıştır!",
              sender: Sender.system)));
      final SharedPreferences prefs = await state.prefs;
      prefs.setString("email", event.email);
      prefs.setString("password", event.password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
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
        print(e);
        add(AppErrorOccured(details: e.message!));
        return;
      }
    }
    emit(state.copyWith(screen: Screen.chatScreen));
    return;
  }

  void appUserSignedUp(AppUserSignedUp event, Emitter emit) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      _userSetup(uid: credential.user!.uid, userName: event.userName);
      add(AppFirebaseDataRead(credential: credential));
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
      "credits": 500,
      "accountLevel": "free"
    }).then((value) {
      print("New user sucesfully created");
    });
  }

  void appFirebaseDataRead(AppFirebaseDataRead event, Emitter emit) async {
    try {
      final String uid = event.credential.user!.uid;
      if (state.loggedIn == false) {
        final DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection("Users").doc(uid).get();
        print("$userData \n");
        final String userName = await userData.get("userName") as String;
        final String accountLevel =
            await userData.get("accountLevel") as String;
        final List messages = await userData.get("messages") as List<dynamic>;

        final List senders =
            await userData.get("messageSenders") as List<dynamic>;
        final List<Message> decodedMessages = <Message>[];
        final int credits = await userData.get("credits");

        AccountLevel decodedAccountLevel = AccountLevel.free;
        if (accountLevel == "associate") {
          decodedAccountLevel = AccountLevel.associate;
        } else if (accountLevel == "professor") {
          decodedAccountLevel = AccountLevel.professor;
        }

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
            messages: decodedMessages,
            userName: userName,
            credits: credits,
            credential: event.credential,
            loggedIn: true,
            accountLevel: decodedAccountLevel,
            screen: Screen.chatScreen));
      } else {
        add(const AppErrorOccured(
            details: "App failed to load data from cloud firestore!"));
        return;
      }
    } catch (e) {
      add(AppErrorOccured(details: e.toString()));
    }
    print("!!!!!!!!!data read!!!!!!!!!!!!!");
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
        currentAcountMenu: AccountMenu.login,
        accountLevel: AccountLevel.free));
    add(AppMessageWritten(
        message:
            Message(context: "Hesabından çıktın.", sender: Sender.system)));
    SharedPreferences prefs = await state.prefs;
    await prefs.setString("email", "");
    await prefs.setString("password", "");
  }

  void appCreditsConsumed(AppCreditsConsumed event, Emitter emit) async {
    int creditCost = (event.text.length ~/ 3) + 1;
    if (state.accountLevel == AccountLevel.professor) {
      creditCost = (creditCost ~/ 100) * 90;
    }
    emit(state.copyWith(credits: state.credits - creditCost));
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    await users
        .doc(state.credential!.user!.uid)
        .set({"credits": state.credits}, SetOptions(merge: true));
  }

  void appShopMenuChanged(AppShopMenuChanged event, Emitter emit) {
    emit(state.copyWith(currentShopMenu: event.menu));
  }

  void appCreditsPurchased(AppCreditsPurchased event, Emitter emit) async {
    final CreditType type = event.type;
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");

    if (type == CreditType.small) {
      emit(state.copyWith(credits: state.credits + 2500));
      add(AppMessageWritten(
          message: Message(
              context:
                  "2500 Biljet değerindeki satın alınımınız tamamlanmıştır.",
              sender: Sender.system)));
      await users
          .doc(state.credential!.user!.uid)
          .set({"credits": state.credits}, SetOptions(merge: true));
    } else if (type == CreditType.middle) {
      emit(state.copyWith(credits: state.credits + 25000));
      add(AppMessageWritten(
          message: Message(
              context:
                  "25000 Biljet değerindeki satın alınımınız tamamlanmıştır.",
              sender: Sender.system)));
      await users
          .doc(state.credential!.user!.uid)
          .set({"credits": state.credits}, SetOptions(merge: true));
    } else if (type == CreditType.big) {
      emit(state.copyWith(credits: state.credits + 250000));
      add(AppMessageWritten(
          message: Message(
              context:
                  "250000 Biljet değerindeki satın alınımınız tamamlanmıştır.",
              sender: Sender.system)));
      await users
          .doc(state.credential!.user!.uid)
          .set({"credits": state.credits}, SetOptions(merge: true));
    }
  }

  void appAccountLevelUpgraded(
      AppAccountLevelUpgraded event, Emitter emit) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("Users");
    String messageContext = "";
    if (event.purchasedLevel == AccountLevel.associate) {
      messageContext = "DOÇENT seviyesi satım alınımınız tamamlanmıştır!";
      users
          .doc(state.credential!.user!.uid)
          .set({"accountLevel": "associate"}, SetOptions(merge: true));
    } else if (event.purchasedLevel == AccountLevel.professor) {
      messageContext = "PROFESÖR seviyesi satım alınımınız tamamlanmıştır!";
      users
          .doc(state.credential!.user!.uid)
          .set({"accountLevel": "professor"}, SetOptions(merge: true));
    }
    emit(state.copyWith(accountLevel: event.purchasedLevel));
    add(AppMessageWritten(
        message: Message(context: messageContext, sender: Sender.system)));
  }

  void appErrorOccured(AppErrorOccured event, Emitter emit) async {
    String errorVictimUuid = "User not logged in.";
    if (state.loggedIn) {
      errorVictimUuid = state.credential!.user!.uid;
    }
    final CollectionReference errors =
        FirebaseFirestore.instance.collection("Errors");
    await errors.doc(uuid.v8()).set({
      "errorDetails": event.details,
      "errorVictimUuid": errorVictimUuid,
      "errorTime": DateTime.now(),
    });
  }
}
