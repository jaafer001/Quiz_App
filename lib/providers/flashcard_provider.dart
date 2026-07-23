import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';

class FlashcardProvider extends ChangeNotifier {

  final StorageService _storage = StorageService();

  List<Flashcard> _cards = [];

  List<Flashcard> get cards => _cards;
  int get cardCount => _cards.length;
  bool get isEmpty => _cards.isEmpty;
  bool get isNotEmpty => _cards.isNotEmpty;

  Future<void> init() async {
    await _storage.init();
    await loadCards();
  }

  Future<void> loadCards() async {
    _cards = _storage.getAllCards();
    notifyListeners();
  }

  Flashcard? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCard(Flashcard card) async {
    await _storage.addCard(card);
    await loadCards();
  }

  Future<void> updateCard(Flashcard card) async {
    await _storage.updateCard(card);
    await loadCards();
  }

  Future<void> deleteCard(String id) async {
    await _storage.deleteCard(id);
    await loadCards();
  }

  Future<void> deleteAllCards() async {
    await _storage.deleteAllCards();
    await loadCards();
  }

  Flashcard? getRandomCard() {
    if (_cards.isEmpty) return null;
    return _cards[DateTime.now().millisecondsSinceEpoch % _cards.length];
  }
}