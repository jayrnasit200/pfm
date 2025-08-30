import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late String title;
  late double amount;

  @Index() // enables fast range queries
  late DateTime date;

  // Store categoryId for simple fast filtering
  @Index()
  late int categoryId;

  String? note;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
