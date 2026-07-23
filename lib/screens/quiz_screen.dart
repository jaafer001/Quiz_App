import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Screen"),
      ),
      body: Row(children: [
        const Text("This is the quiz screen"),
        ElevatedButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text("go back"))
      ]),
    );
  }
}
