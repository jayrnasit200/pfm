import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../models/job.dart';
import '../models/goal.dart';
import '../models/earning.dart';
import '../models/user.dart';

class LocalDb {
  static Isar? _isar;

  /// Safe access
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Isar is not initialized. Call LocalDb.init() first.');
    }
    return _isar!;
  }

  static Future<void> init() async {
    if (_isar != null) return; // prevent double open

    try {
      if (kIsWeb) {
        // WEB: no directory
        _isar = await Isar.open(
          [
            ExpenseSchema,
            CategorySchema,
            TaskSchema,
            UserSchema,
            JobSchema,
            GoalSchema,
            EarningSchema,
          ],
          directory: '',
        );
      } else {
        // MOBILE: use app directory
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [
            ExpenseSchema,
            CategorySchema,
            TaskSchema,
            UserSchema,
            JobSchema,
            GoalSchema,
            EarningSchema,
          ],
          directory: dir.path,
        );
      }

      await _seedCategoriesIfNeeded();
    } catch (e) {
      debugPrint('❌ Isar init error: $e');
      rethrow;
    }
  }

  static Future<void> _seedCategoriesIfNeeded() async {
    final count = await isar.categorys.count();
    if (count > 0) return;

    await isar.writeTxn(() async {
      await isar.categorys.putAll([
        Category(name: 'Food'),
        Category(name: 'Transport'),
        Category(name: 'Bills'),
        Category(name: 'Shopping'),
        Category(name: 'Other'),
      ]);
    });
  }
}
