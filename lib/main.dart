import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/api_key.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';
import 'package:flutter_chatbot/screens/chat/chat_screen.dart';
//import 'package:flutter_chatbot/screens/chat/config_ai_popup.dart';
import 'package:flutter_chatbot/screens/loading/loading_screen.dart';
import 'package:flutter_chatbot/screens/welcome/welcome_screen.dart';
import 'package:flutter_chatbot/widgets/drawer.dart';
import 'package:flutter_chatbot/screens/about/about_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:firebase_auth/firebase_auth.dart';

late String prompt;
late FirebaseAuth auth;
void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  // ignore: unused_local_variable
  final FirebaseApp firebase = await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: firebaseApiKey,
    appId: firebaseAppID,
    messagingSenderId: firebaseMessagingSenderID,
    projectId: firebaseProjectID,
  ));

  Trace appLaunch = FirebasePerformance.instance.newTrace("appLaunch");
  appLaunch.start();
  auth = FirebaseAuth.instance;  

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 5),
      minimumFetchInterval: const Duration(hours: 1),
    ),
  );
  await remoteConfig.fetchAndActivate();
  prompt = remoteConfig.getString("prompt");
  final String openAiApiKey = remoteConfig.getString('openAiApiKey');
  final String pineconeApiKey = remoteConfig.getString("pineconeApiKey");
  final String pineconeEnvironment =
      remoteConfig.getString("pineconeEnvironment");
  final String pineconeIndexName = remoteConfig.getString("pineconeIndexName");
  embeddings = OpenAIEmbeddings(apiKey: openAiApiKey);
  llm = ChatOpenAI(apiKey: openAiApiKey);

  vectorStore = Pinecone(
      apiKey: pineconeApiKey,
      indexName: pineconeIndexName,
      embeddings: embeddings,
      environment: pineconeEnvironment);
  qaChain = RetrievalQAChain.fromLlm(
    llm: llm,
    retriever: vectorStore.asRetriever(
      defaultOptions: VectorStoreRetrieverOptions(
        searchType: VectorStoreSearchType.similarity(),
      ),
    ),
  );
  FlutterNativeSplash.remove();
  appLaunch.stop();
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
                  title: Row(
                    children: [
                      const Text('Hocam Bot'),
                      if (state.accountLevel == AccountLevel.associate)
                        SizedBox(
                            height: 50,
                            width: 150,
                            child: Image.asset(
                              "assets/account_level_icons/associate.png",
                            ))
                      else if (state.accountLevel == AccountLevel.professor)
                        SizedBox(
                            height: 60,
                            width: 150,
                            child: Image.asset(
                                "assets/account_level_icons/proffesor.png"))
                    ],
                  ),
                  actions: [
                    if (state.loggedIn)
                      if (state.accountLevel == AccountLevel.professor)
                        Image.asset(
                          "assets/biljet/bj_premium.png",
                          height: 32.5,
                          width: 35,
                        )
                      else
                        Image.asset(
                          "assets/biljet/bj_normal.png",
                          height: 35,
                          width: 35,
                        ),
                    if (state.loggedIn)
                      const SizedBox(
                        width: 3,
                      ),
                    if (state.loggedIn)
                      Text(
                        state.credits.toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    const SizedBox(
                      width: 5,
                    ),
                    /*if (state.screen == Screen.chatScreen)
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ConfigAIPopup(),
                          );
                        },
                        icon: const Icon(Icons.smart_toy_outlined),
                        tooltip: "Hocam Bot ayarları.",
                      ),*/
                    if (state.screen == Screen.chatScreen)
                      IconButton(
                        onPressed: () {
                          context
                              .read<AppBloc>()
                              .add(const AppChatHistoryCleared());
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
