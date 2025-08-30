import 'package:isar/isar.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String name;
  late double targetAmount;
  double savedAmount = 0.0;

  /// Added deadline field ✅
  late DateTime deadline;
}
