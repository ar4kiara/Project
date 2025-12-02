import 'dart:async';

import '../datasources/debt_local_storage.dart';
import '../models/debt_entry.dart';

abstract class DebtRepository {
  Stream<List<DebtEntry>> watchEntries();

  Future<void> save(DebtEntry entry);

  Future<void> delete(String id);

  Future<void> clear();
}

class SqfliteDebtRepository implements DebtRepository {
  SqfliteDebtRepository(this._storage);

  final DebtLocalStorage _storage;
  final _controller = StreamController<List<DebtEntry>>.broadcast();

  Future<void> _emit() async {
    final data = await _storage.getAll();
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.clear();
    await _emit();
  }

  @override
  Future<void> delete(String id) async {
    await _storage.delete(id);
    await _emit();
  }

  @override
  Future<void> save(DebtEntry entry) async {
    await _storage.insertOrUpdate(entry);
    await _emit();
  }

  @override
  Stream<List<DebtEntry>> watchEntries() {
    _emit();
    return _controller.stream;
  }

  Future<void> dispose() async {
    await _storage.close();
    await _controller.close();
  }
}

class MemoryDebtRepository implements DebtRepository {
  MemoryDebtRepository();

  final _entries = <DebtEntry>[];
  final _controller = StreamController<List<DebtEntry>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_entries));

  @override
  Future<void> clear() async {
    _entries.clear();
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((element) => element.id == id);
    _emit();
  }

  @override
  Future<void> save(DebtEntry entry) async {
    final index = _entries.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      _entries[index] = entry;
    } else {
      _entries.add(entry);
    }
    _emit();
  }

  @override
  Stream<List<DebtEntry>> watchEntries() {
    _emit();
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}

