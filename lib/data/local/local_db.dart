import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/task.dart';

class LocalDb {
  static Isar? _isar;
  static Isar get isar => _isar!;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar ??= await Isar.open(
      [ExpenseSchema, CategorySchema, TaskSchema],
      directory: dir.path,
    );

    // Optional: seed default categories once
    final hasCategories = await _isar!.categorys.count() > 0;
    if (!hasCategories) {
      await _isar!.writeTxn(() async {
        await _isar!.categorys.putAll([
          Category()..name = 'Food',
          Category()..name = 'Transport',
          Category()..name = 'Bills',
          Category()..name = 'Shopping',
          Category()..name = 'Other',
        ]);
      });
    }
  }
}
