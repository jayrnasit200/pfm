import 'package:isar/isar.dart';

part 'earning.g.dart';

@Collection()
class Earning {
  Id id = Isar.autoIncrement;

  late String category;
  late double amount;
  late DateTime dateEarned;

  int? jobId; // ✅ Added for filtering by job
}
