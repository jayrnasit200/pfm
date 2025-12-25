import 'package:isar/isar.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  String name;
  double targetAmount;
  double savedAmount;
  DateTime deadline;

  DateTime createdAt;
  DateTime updatedAt;

  Goal({
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.deadline,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void touch() {
    updatedAt = DateTime.now();
  }
}
