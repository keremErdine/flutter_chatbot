part of 'app_bloc.dart';

class AppEvent {}

class AppDocumentAdded extends AppEvent {
  AppDocumentAdded({required this.document});
  final XFile document;
}

class AppMessageWritten extends AppEvent {
  AppMessageWritten({required this.message});
  final Message message;
}

@immutable
class AppAIStartedGeneratingResponse extends AppEvent {}

@immutable
class AppAIFinishedGeneratingResponse extends AppEvent {}

class AppScreenChanged extends AppEvent {
  AppScreenChanged({required this.screen});
  Screen screen;
}

@immutable
class AppChatHistoryCleared extends AppEvent {}
