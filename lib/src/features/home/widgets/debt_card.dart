import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/debt_entry.dart';
import '../../../data/repositories/debt_repository_provider.dart';
import '../../../utils/currency_formatter.dart';
import 'debt_form_sheet.dart';

class DebtCard extends ConsumerStatefulWidget {
  const DebtCard({super.key, required this.entry});

  final DebtEntry entry;

  @override
  ConsumerState<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends ConsumerState<DebtCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isOverdue {
    if (widget.entry.jatuhTempo == null) return false;
    return widget.entry.jatuhTempo!.isBefore(DateTime.now());
  }

  bool get _isDueSoon {
    if (widget.entry.jatuhTempo == null) return false;
    final now = DateTime.now();
    final dueDate = widget.entry.jatuhTempo!;
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 7;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = CurrencyFormatter();
    final isPinjam = widget.entry.isPinjam;
    final bgColor = isPinjam ? Colors.red.shade50 : Colors.green.shade50;
    final borderColor = isPinjam ? Colors.red.shade200 : Colors.green.shade200;
    final iconColor = isPinjam ? Colors.red.shade700 : Colors.green.shade700;
    final amountColor = isPinjam ? Colors.red.shade700 : Colors.green.shade700;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isOverdue
                ? Colors.red.shade400
                : _isDueSoon
                    ? Colors.orange.shade300
                    : borderColor,
            width: _isOverdue || _isDueSoon ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withOpacity(0.5),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPinjam ? Icons.call_received : Icons.call_made,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entry.contactName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.entry.jatuhTempo != null)
                            _DueDateBadge(
                              dueDate: widget.entry.jatuhTempo!,
                              isOverdue: _isOverdue,
                              isDueSoon: _isDueSoon,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Tidak ada jatuh tempo',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openSheet(context);
                        } else if (value == 'delete') {
                          _delete(ref, context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPinjam ? 'Jumlah Pinjam' : 'Jumlah Bayar',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(widget.entry.nominal),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: amountColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPinjam ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPinjam ? 'PINJAM' : 'BAYAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPinjam ? Colors.red.shade900 : Colors.green.shade900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.entry.keterangan != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.entry.keterangan!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Dibuat: ${DateFormat('dd MMM yyyy, HH:mm').format(widget.entry.dibuatPada)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DebtFormSheet(existing: widget.entry),
    );
  }

  Future<void> _delete(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: Text('Apakah Anda yakin ingin menghapus data ${widget.entry.contactName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(debtRepositoryProvider);
      await repo.delete(widget.entry.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data ${widget.entry.contactName} dihapus'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo if needed
              },
            ),
          ),
        );
      }
    }
  }
}

class _DueDateBadge extends StatelessWidget {
  const _DueDateBadge({
    required this.dueDate,
    required this.isOverdue,
    required this.isDueSoon,
  });

  final DateTime dueDate;
  final bool isOverdue;
  final bool isDueSoon;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    Color badgeColor;
    Color textColor;
    String text;
    IconData icon;

    if (isOverdue) {
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      text = 'Terlambat ${difference.abs()} hari';
      icon = Icons.warning;
    } else if (isDueSoon) {
      badgeColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
      text = difference == 0 ? 'Hari ini jatuh tempo!' : 'Jatuh tempo dalam $difference hari';
      icon = Icons.schedule;
    } else {
      badgeColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
      text = 'Jatuh tempo: ${dateFormat.format(dueDate)}';
      icon = Icons.calendar_today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

