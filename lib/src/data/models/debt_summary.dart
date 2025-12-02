import 'debt_entry.dart';

class DebtSummary {
  DebtSummary(this.entries);

  final List<DebtEntry> entries;

  int get totalPinjam => entries
      .where((e) => e.isPinjam)
      .fold(0, (sum, e) => sum + e.nominal);

  int get totalBayar => entries
      .where((e) => e.isBayar)
      .fold(0, (sum, e) => sum + e.nominal);

  int get sisaHutang => totalPinjam - totalBayar;
}

