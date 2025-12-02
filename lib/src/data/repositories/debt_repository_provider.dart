import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/app_mode.dart';
import '../../core/providers/app_mode_provider.dart';
import '../datasources/debt_local_storage.dart';
import 'debt_repository.dart';

final debtLocalStorageProvider = Provider<DebtLocalStorage>((ref) {
  final storage = DebtLocalStorage();
  ref.onDispose(storage.close);
  return storage;
});

final sqfliteDebtRepositoryProvider = Provider<DebtRepository>((ref) {
  final storage = ref.watch(debtLocalStorageProvider);
  final repo = SqfliteDebtRepository(storage);
  ref.onDispose(repo.dispose);
  return repo;
});

final memoryDebtRepositoryProvider = Provider<MemoryDebtRepository>((ref) {
  final repo = MemoryDebtRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final mode = ref.watch(activeModeProvider);
  if (mode == AppMode.developer) {
    return ref.watch(memoryDebtRepositoryProvider);
  }
  return ref.watch(sqfliteDebtRepositoryProvider);
});

