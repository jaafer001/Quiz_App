import 'package:hive_flutter/hive_flutter.dart';
import '../models/flashcard.dart';

class StorageService {
  static const String _boxName = 'flashcards_box';

  late Box<Flashcard> _box;


  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(FlashcardAdapter());

    _box = await Hive.openBox<Flashcard>(_boxName);
  }


  List<Flashcard> getAllCards() {
    return _box.values.toList();
  }

  Flashcard? getCard(String id) {
    return _box.get(id);
  }

  int getCardCount() {
    return _box.length;
  }

  bool isEmpty() {
    return _box.isEmpty;
  }

  bool containsCard(String id) {
    return _box.containsKey(id);
  }


  Future<void> addCard(Flashcard card) async {
    await _box.put(card.id, card);
  }

  Future<void> addCards(List<Flashcard> cards) async {
    final Map<String, Flashcard> cardMap = {
      for (var card in cards) card.id: card,
    };
    await _box.putAll(cardMap);
  }


  Future<void> updateCard(Flashcard card) async {
    await _box.put(card.id, card);
  }

  Future<void> updateCards(List<Flashcard> cards) async {
    final Map<String, Flashcard> cardMap = {
      for (var card in cards) card.id: card,
    };
    await _box.putAll(cardMap);
  }


  Future<void> deleteCard(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteCards(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  Future<void> deleteAllCards() async {
    await _box.clear();
  }


  List<Flashcard> searchByQuestion(String query) {
    if (query.isEmpty) return getAllCards();

    return _box.values.where((card) {
      return card.question.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Flashcard> searchByAnswer(String query) {
    if (query.isEmpty) return getAllCards();

    return _box.values.where((card) {
      return card.answer.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Flashcard> search(String query) {
    if (query.isEmpty) return getAllCards();

    final lowerQuery = query.toLowerCase();
    return _box.values.where((card) {
      return card.question.toLowerCase().contains(lowerQuery) ||
          card.answer.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  int countByKeyword(String keyword) {
    return _box.values.where((card) {
      return card.question.contains(keyword) ||
          card.answer.contains(keyword);
    }).length;
  }

  List<Flashcard> getRandomCards(int count) {
    final allCards = getAllCards();
    if (allCards.isEmpty || count <= 0) return [];

    final randomCount = count > allCards.length ? allCards.length : count;
    allCards.shuffle();
    return allCards.take(randomCount).toList();
  }

  Flashcard? getRandomCard() {
    final allCards = getAllCards();
    if (allCards.isEmpty) return null;
    return allCards[DateTime.now().millisecondsSinceEpoch % allCards.length];
  }



  List<Map<String, dynamic>> exportToJson() {
    return _box.values.map((card) => card.toJson()).toList();
  }

  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {
    final cards = jsonList.map((json) => Flashcard.fromJson(json)).toList();
    await addCards(cards);
  }


  Future<void> close() async {
    await _box.close();
  }

  Future<void> deleteBox() async {
    await _box.deleteFromDisk();
  }

  void compact() {
    _box.compact();
  }



  List<String> getAllIds() {
    return _box.keys.cast<String>().toList();
  }

  Flashcard? getLastCard() {
    final allCards = getAllCards();
    if (allCards.isEmpty) return null;
    return allCards.last;
  }

  Flashcard? getFirstCard() {
    final allCards = getAllCards();
    if (allCards.isEmpty) return null;
    return allCards.first;
  }

  List<Flashcard> getCardsSortedByQuestion() {
    final cards = getAllCards();
    cards.sort((a, b) => a.question.compareTo(b.question));
    return cards;
  }

  List<Flashcard> getCardsSortedByDate() {
    final cards = getAllCards();
    cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  int getTodayCards() {
    final today = DateTime.now();
    return _box.values.where((card) {
      return card.createdAt.year == today.year &&
          card.createdAt.month == today.month &&
          card.createdAt.day == today.day;
    }).length;
  }

  Map<String, int> getCardsPerMonth() {
    final Map<String, int> result = {};
    for (var card in _box.values) {
      final key = '${card.createdAt.year}-${card.createdAt.month}';
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}