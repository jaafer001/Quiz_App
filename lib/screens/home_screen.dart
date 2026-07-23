import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../themes/app_themes.dart';
import '../widgets/flashcard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Quiz App",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.white,
            iconSize: 30,
            alignment: Alignment.centerRight,
            onPressed: () {
              const AlertDialog(
                title: Text("Settings"),
                content: Text("This is the settings page"),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: AppTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/quiz');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: const BorderSide(
                  width: 0.5,
                  color: Colors.white,
                ),
              ),
              child: const Text("Start Quiz"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.cards.length,
                itemBuilder: (context, index) {
                  final card = provider.cards[index];

                  return FlashcardCard(
                    card: card,
                    onEdit: () => _navigateToEdit(context, card.id),
                    onDelete: () => _deleteCard(context, card.id),
                  );
                },
              ),
            ),
          ],
        ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/add');
          },

          backgroundColor: AppTheme.primary,
          child: const Icon(
              Icons.add,
              color: Colors.white,
          ),
        ),
      );
  }

}

void _navigateToEdit(BuildContext context, String cardId) {
  Navigator.pushNamed(context, '/edit/$cardId');
}
void _deleteCard(BuildContext context, id) {
  context.read<FlashcardProvider>().deleteCard(id);
}
