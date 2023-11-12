import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/screens/main/main_screen.dart';
import 'package:flutter_chatbot/widgets/drawer.dart';
import 'package:flutter_chatbot/screens/about/about_screen.dart';

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = const MainScreen();
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hocam Bot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(
            drawer: const MainDrawer(),
            body: BlocConsumer<AppBloc, AppState>(
              listener: (context, state) {
                if (state.screen == Screen.mainScreen) {
                  activeScreen = const MainScreen();
                } else if (state.screen == Screen.aboutScreen) {
                  activeScreen = const AboutScreen();
                }
              },
              builder: (context, state) {
                return activeScreen;
              },
            )),
      ),
    );
  }
}
