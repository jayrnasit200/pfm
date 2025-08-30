import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String description;
  bool isCompleted = false;

  @Index()
  DateTime? dueDate;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
