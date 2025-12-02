import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/app_mode.dart';
import '../../core/providers/app_mode_provider.dart';
import '../../data/models/debt_entry.dart';
import '../../data/models/debt_summary.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/debt_repository_provider.dart';
import '../../data/services/pin_service_provider.dart';
import '../../utils/currency_formatter.dart';
import 'providers/debt_providers.dart';
import 'widgets/debt_form_sheet.dart';
import 'widgets/debt_card.dart';
import 'widgets/export_bottom_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Auto clear data untuk mode developer saat aplikasi ditutup
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      final mode = ref.read(activeModeProvider);
      if (mode == AppMode.developer) {
        final repo = ref.read(debtRepositoryProvider);
        repo.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(activeModeProvider);
    if (mode == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Silakan pilih mode terlebih dahulu.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Kembali ke menu awal'),
              ),
            ],
          ),
        ),
      );
    }

    final debts = ref.watch(debtEntriesProvider);
    final summary = ref.watch(debtSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${mode.label}'),
        actions: [
          IconButton(
            onPressed: () => _openExport(context),
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            onPressed: () => _showSettings(context, ref),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
      ),
      body: debts.when(
        data: (list) => _HomeBody(
          summary: summary,
          entries: list,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Terjadi kesalahan: $error'),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, [DebtEntry? entry]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DebtFormSheet(existing: entry),
    );
  }

  void _openExport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExportBottomSheet(),
    );
  }

  Future<void> _showSettings(BuildContext context, WidgetRef ref) async {
    final mode = ref.read(activeModeProvider);
    final repo = ref.read(debtRepositoryProvider);
    final pinService = ref.read(pinServiceProvider);

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Bersihkan semua catatan'),
                  subtitle: const Text('Hapus seluruh data transaksi saat ini'),
                  onTap: () async {
                    await repo.clear();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                if (mode == AppMode.user)
                  ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Reset PIN'),
                    subtitle:
                        const Text('Hapus PIN saat ini lalu buat ulang nanti'),
                    onTap: () async {
                      await pinService.remove();
                      if (!context.mounted) return;
                      ref.read(activeModeProvider.notifier).state = null;
                      context.go('/');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Keluar ke menu awal'),
                  onTap: () {
                    ref.read(activeModeProvider.notifier).state = null;
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.summary, required this.entries});

  final DebtSummary summary;
  final List<DebtEntry> entries;

  Future<void> _refreshData(WidgetRef ref) async {
    // Trigger refresh dengan membaca ulang repository
    final repo = ref.read(debtRepositoryProvider);
    // Force emit untuk refresh stream
    if (repo is SqfliteDebtRepository) {
      // Repository akan auto refresh melalui stream
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinjam = entries.where((e) => e.isPinjam).toList();
    final bayar = entries.where((e) => e.isBayar).toList();
    final sisaHutang = summary.sisaHutang;

    return RefreshIndicator(
      onRefresh: () => _refreshData(ref),
      color: Theme.of(context).colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        children: [
          _SummaryRow(summary: summary, sisaHutang: sisaHutang),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Hutang',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (entries.isNotEmpty)
                Chip(
                  label: Text('${entries.length} item'),
                  avatar: const Icon(Icons.list, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _EmptyState(
              title: 'Belum ada data',
              subtitle:
                  'Tekan tombol catat untuk menambahkan pinjaman atau pembayaran.',
              icon: Icons.receipt_long,
            )
          else
            ...entries.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (entry.key * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: DebtCard(entry: entry.value),
                  ),
                )),
          const SizedBox(height: 24),
          Text(
            'Histori Cerdas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _HistorySection(title: 'Pinjam', data: pinjam),
          const SizedBox(height: 12),
          _HistorySection(title: 'Bayar', data: bayar),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary, required this.sisaHutang});
  final DebtSummary summary;
  final int sisaHutang;

  @override
  Widget build(BuildContext context) {
    final currency = CurrencyFormatter();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Pinjam',
                value: currency.format(summary.totalPinjam),
                icon: Icons.call_received,
                color: Colors.red.shade50,
                iconColor: Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Bayar',
                value: currency.format(summary.totalBayar),
                icon: Icons.call_made,
                color: Colors.green.shade50,
                iconColor: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: sisaHutang > 0
                  ? [Colors.orange.shade100, Colors.orange.shade50]
                  : [Colors.green.shade100, Colors.green.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sisaHutang > 0
                  ? Colors.orange.shade300
                  : Colors.green.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  sisaHutang > 0 ? Icons.warning_amber : Icons.check_circle,
                  color: sisaHutang > 0
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sisa Hutang',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(sisaHutang),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: sisaHutang > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends ConsumerWidget {
  const _HistorySection({required this.title, required this.data});

  final String title;
  final List<DebtEntry> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) {
      return _EmptyState(
        title: '$title kosong',
        subtitle: 'Belum ada transaksi $title.',
      );
    }
    final formatter = DateFormat('dd MMM yyyy');
    final currency = CurrencyFormatter();
    return Column(
      children: data
          .map(
            (e) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(e.contactName),
              subtitle: Text(
                '${formatter.format(e.dibuatPada)} • ${e.keterangan ?? '-'}',
              ),
              trailing: Text(
                currency.format(e.nominal),
                style: TextStyle(
                  color: e.isPinjam
                      ? Colors.redAccent
                      : Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

