import 'package:isar/isar.dart';

part 'earning.g.dart';

@collection
class Earning {
  Id id = Isar.autoIncrement;

  late double amount;

  /// Optional job reference
  int? jobId;

  /// Label / note
  late String category;

  /// When earning was created
  late DateTime dateEarned;

  /// REQUIRED: "pending" or "paid"
  late String status;
}
