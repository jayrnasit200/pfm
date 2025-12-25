import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  String title;
  double amount;

  @Index()
  DateTime date;

  @Index()
  int categoryId;

  String? note;

  DateTime createdAt;
  DateTime updatedAt;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// Call this before saving updates
  void touch() {
    updatedAt = DateTime.now();
  }
}
