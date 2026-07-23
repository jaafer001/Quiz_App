import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/routers/app_router.dart';
import 'package:quiz_app/providers/flashcard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = FlashcardProvider();
  await provider.init();
  runApp(MyApp(flashcardProvider: provider));
}

class MyApp extends StatelessWidget {
  final FlashcardProvider flashcardProvider;

  const MyApp({super.key, required this.flashcardProvider});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FlashcardProvider>.value(
      value: flashcardProvider,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        routerConfig: appRouter,
      ),
    );
  }
}