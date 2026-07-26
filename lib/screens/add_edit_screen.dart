import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../utils/validators.dart';
import '../widgets/gradient_button.dart';

class AddEditScreen extends StatefulWidget {
  final String? cardId;
  const AddEditScreen({super.key, this.cardId});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  bool _isEditing = false;
  final _uuid = Uuid();
  bool _previewShowAnswer = false;

  static const int _maxChars = 280;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.cardId != null;
    _questionController = TextEditingController();
    _answerController = TextEditingController();

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final card =
        context.read<FlashcardProvider>().getCardById(widget.cardId!);
        if (card != null) {
          _questionController.text = card.question;
          _answerController.text = card.answer;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _questionController.text.trim().isNotEmpty &&
          _answerController.text.trim().isNotEmpty;

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<FlashcardProvider>();
      if (_isEditing) {
        final existingCard = provider.getCardById(widget.cardId!);
        if (existingCard != null) {
          final updatedCard = existingCard.copyWith(
            question: _questionController.text.trim(),
            answer: _answerController.text.trim(),
          );
          provider.updateCard(updatedCard);
        }
      } else {
        final newCard = Flashcard(
          id: _uuid.v4(),
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
        );
        provider.addCard(newCard);
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              _isEditing ? 'Flashcard updated' : 'Flashcard saved',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(milliseconds: 1200),
          ),
        );

      context.pop();
    }
  }

  void _togglePreview() {
    setState(() => _previewShowAnswer = !_previewShowAnswer);
  }

  bool _showDiscardDialog = false;

  Future<bool> _confirmDiscard() async {
    if (_questionController.text.trim().isEmpty &&
        _answerController.text.trim().isEmpty) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          toolbarHeight: 48,
          titleSpacing: 20,
          title: Text(
            _isEditing ? 'Edit Flashcard' : 'New Flashcard',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          actions: [
            if (_isEditing)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, size: 22),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete flashcard?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style:
                          TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    context.read<FlashcardProvider>().deleteCard(widget.cardId!);
                    context.pop();
                  }
                },
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Tap the card to preview the flip',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Live preview card
                    GestureDetector(
                      onTap: _togglePreview,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0.0, end: _previewShowAnswer ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        builder: (context, v, child) {
                          final angle = v * pi;
                          final isBack = v > 0.5;
                          final displayText = isBack
                              ? _answerController.text
                              : _questionController.text;
                          final header = isBack ? 'ANSWER' : 'QUESTION';

                          final gradient = isBack
                              ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.secondary,
                              scheme.secondary.withOpacity(0.75),
                            ],
                          )
                              : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withOpacity(0.10),
                              scheme.primary.withOpacity(0.03),
                            ],
                          );

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateY(angle),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateY(isBack ? pi : 0),
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: gradient,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isBack
                                        ? Colors.transparent
                                        : scheme.primary.withOpacity(0.15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isBack
                                          ? scheme.secondary
                                          : scheme.primary)
                                          .withOpacity(0.18),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isBack
                                            ? Colors.white.withOpacity(0.2)
                                            : scheme.primary.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        header,
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          color: isBack
                                              ? Colors.white
                                              : scheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          displayText.isEmpty
                                              ? (isBack
                                              ? 'Your answer will appear here'
                                              : 'Your question will appear here')
                                              : displayText,
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.3,
                                            color: displayText.isEmpty
                                                ? (isBack
                                                ? Colors.white70
                                                : scheme.onSurfaceVariant)
                                                : (isBack
                                                ? Colors.white
                                                : scheme.onSurface),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    _FieldLabel(text: 'Question', icon: Icons.help_outline_rounded),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _questionController,
                      decoration: _fieldDecoration(
                        context,
                        hint: 'What do you want to be asked?',
                      ),
                      maxLines: 4,
                      maxLength: _maxChars,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateQuestion,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    _FieldLabel(text: 'Answer', icon: Icons.lightbulb_outline_rounded),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _answerController,
                      decoration: _fieldDecoration(
                        context,
                        hint: 'What is the correct answer?',
                      ),
                      maxLines: 4,
                      maxLength: _maxChars,
                      textInputAction: TextInputAction.done,
                      validator: Validators.validateAnswer,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 28),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _canSave ? 1 : 0.5,
                      child: GradientButton(
                        onPressed: _canSave ? _saveForm : () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEditing
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing ? 'Update Card' : 'Save Card',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        if (await _confirmDiscard() && mounted) context.pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, {required String hint}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      counterStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 1.2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FieldLabel({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}