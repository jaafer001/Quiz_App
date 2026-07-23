import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/quiz_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addCard = '/add';
  static const String editCard = '/edit/:id';
  static const String quiz = '/quiz';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.addCard,
      name: 'addCard',
      builder: (context, state) => const AddEditScreen(),
    ),

    GoRoute(
      path: AppRoutes.editCard,
      name: 'editCard',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddEditScreen(cardId: id);
      },
    ),

    GoRoute(
      path: AppRoutes.quiz,
      name: 'quiz',
      builder: (context, state) => const QuizScreen(),
    ),
  ],

);