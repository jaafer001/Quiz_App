import 'package:hive_flutter/hive_flutter.dart';

part 'flashcard.g.dart';  // ✅ سيتم إنشاؤه تلقائياً

@HiveType(typeId: 0)  // ✅ معرف النوع (يجب أن يكون فريداً)
class Flashcard extends HiveObject {
  @HiveField(0)  // ✅ معرف الحقل
  final String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  String answer;

  @HiveField(3)
  DateTime createdAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // نسخ البطاقة مع تعديلات
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ✅ تحويل إلى Map للتخزين (اختياري)
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'createdAt': createdAt.toIso8601String(),
  };

  // ✅ إنشاء من Map
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}