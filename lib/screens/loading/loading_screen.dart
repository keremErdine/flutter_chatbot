import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AppBloc>().add(AppDataFromPrefsRead());
    return const Center(
      child: Text("Veriler alınıyor..."),
    );
  }
}
