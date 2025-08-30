import 'package:isar/isar.dart';
import '../local/local_db.dart';
import '../models/expense.dart';

abstract class IExpenseRepository {
  Future<Id> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(Id id);
  Future<Expense?> get(Id id);
  Future<List<Expense>> all();
  Future<List<Expense>> byMonth(int year, int month);
  Stream<List<Expense>> watchAll();
}

class IsarExpenseRepository implements IExpenseRepository {
  Isar get _db => LocalDb.isar;

  @override
  Future<Id> add(Expense e) async {
    e.createdAt = DateTime.now();
    e.updatedAt = DateTime.now();
    return _db.writeTxn(() => _db.expenses.put(e));
  }

  @override
  Future<void> update(Expense e) async {
    e.updatedAt = DateTime.now();
    await _db.writeTxn(() => _db.expenses.put(e));
  }

  @override
  Future<void> delete(Id id) async {
    await _db.writeTxn(() => _db.expenses.delete(id));
  }

  @override
  Future<Expense?> get(Id id) => _db.expenses.get(id);

  @override
  Future<List<Expense>> all() =>
      _db.expenses.where().sortByDateDesc().findAll();

  @override
  Future<List<Expense>> byMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end =
        DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1));
    // uses date index
    return _db.expenses.where().dateBetween(start, end).findAll();
  }

  @override
  Stream<List<Expense>> watchAll() =>
      _db.expenses.where().sortByDateDesc().watch(fireImmediately: true);
}
