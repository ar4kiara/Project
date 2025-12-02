import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/debt_entry.dart';
import '../../../data/models/debt_summary.dart';
import '../../../data/repositories/debt_repository_provider.dart';

final debtEntriesProvider = StreamProvider<List<DebtEntry>>((ref) {
  final repo = ref.watch(debtRepositoryProvider);
  return repo.watchEntries();
});

final debtSummaryProvider = Provider<DebtSummary>((ref) {
  final entries = ref.watch(debtEntriesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <DebtEntry>[],
      );
  return DebtSummary(entries);
});

