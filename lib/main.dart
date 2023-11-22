import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/screens/chat/chat_screen.dart';
import 'package:flutter_chatbot/screens/chat/config_ai_popup.dart';
import 'package:flutter_chatbot/screens/loading/loading_screen.dart';
import 'package:flutter_chatbot/screens/welcome/welcome_screen.dart';
import 'package:flutter_chatbot/widgets/drawer.dart';
import 'package:flutter_chatbot/screens/about/about_screen.dart';

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = const LoadingScreen();
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hocam Bot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, state) {
            if (state.screen == Screen.chatScreen) {
              activeScreen = const ChatScreen();
            } else if (state.screen == Screen.aboutScreen) {
              activeScreen = const AboutScreen();
            } else if (state.screen == Screen.welcomeScreen) {
              activeScreen = const WelcomeScreen();
            } else {
              activeScreen = const LoadingScreen();
            }
          },
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Hocam Bot'),
                  actions: [
                    if (state.screen == Screen.chatScreen)
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ConfigAIPopup(),
                          );
                        },
                        icon: const Icon(Icons.smart_toy_outlined),
                        tooltip: "Hocam Bot ayarları.",
                      ),
                    if (state.screen == Screen.chatScreen)
                      IconButton(
                        onPressed: () {
                          context.read<AppBloc>().add(AppChatHistoryCleared());
                        },
                        icon: const Icon(
                          Icons.clear_all_outlined,
                        ),
                        tooltip: "Konuşmayı temizle.",
                      )
                  ],
                ),
                drawer: const MainDrawer(),
                body: activeScreen);
          },
        ),
      ),
    );
  }
}
