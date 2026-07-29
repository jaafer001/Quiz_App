import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/empty_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard(int totalCards) {
    setState(() {
      if (_currentIndex < totalCards - 1) {
        _currentIndex++;
        _showAnswer = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showAnswer = false;
      }
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final cards = provider.cards;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          toolbarHeight: 48,
          titleSpacing: 20,
          title: const Text(
            'Quiz',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        body: const EmptyState(
          message: 'No flashcards available to study.\nGo back and add some!',
          icon: Icons.quiz_outlined,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ),
        ),
      );
    }

    final currentCard = cards[_currentIndex];
    final isLastCard = _currentIndex == cards.length - 1;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        toolbarHeight: 48,
        titleSpacing: 20,
        title: const Text(
          'Study Mode',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: QuizProgressIndicator(
                      currentIndex: _currentIndex,
                      totalCount: cards.length,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${cards.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: _toggleAnswer,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == null) return;
                    if (details.primaryVelocity! < 0 && !isLastCard) {
                      _nextCard(cards.length);
                    } else if (details.primaryVelocity! > 0 &&
                        _currentIndex > 0) {
                      _previousCard();
                    }
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: _showAnswer ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      final angle = value * pi;
                      final isBack = value > 0.5;
                      final displayText =
                      isBack ? currentCard.answer : currentCard.question;
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
                          scheme.surface,
                          scheme.surface,
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
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isBack
                                    ? Colors.transparent
                                    : scheme.outlineVariant.withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isBack
                                      ? scheme.secondary.withOpacity(0.18)
                                      : Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                              padding: const EdgeInsets.all(28.0),
                              child: Stack(
                                children: [
                                  // Centered main text
                                  Center(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          displayText,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                            color: isBack
                                                ? Colors.white
                                                : scheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Header badge at top-left
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isBack
                                            ? Colors.white.withOpacity(0.2)
                                            : scheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        header,
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 2,
                                          color: isBack ? Colors.white : scheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Bottom hint row
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 14,
                                          color: isBack
                                              ? Colors.white70
                                              : scheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _showAnswer
                                              ? 'Tap to see question'
                                              : 'Tap to see answer',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isBack
                                                ? Colors.white70
                                                : scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
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
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentIndex > 0 ? _previousCard : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLastCard
                          ? null
                          : () => _nextCard(cards.length),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _toggleAnswer,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.secondary,
                ),
                child: Text(_showAnswer ? 'Show Question' : 'Show Answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}