import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/flashcard.dart';

class FlashcardCard extends StatelessWidget {
  final Flashcard card;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final bool showActions;

  const FlashcardCard({
    super.key,
    required this.card,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark,
                color: Colors.blue,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (showActions) ...[
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: onEdit ?? () {
                  context.push('/edit/${card.id}');
                },
                tooltip: 'تعديل',
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: onDelete ?? () {
                },
                tooltip: 'حذف',
              ),
            ],
          ],
        ),
      ),
    );
  }
}