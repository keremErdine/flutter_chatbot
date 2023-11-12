import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return const Column(
          children: [],
        );
      },
    ));
  }
}
