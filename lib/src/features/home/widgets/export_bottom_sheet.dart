import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/debt_entry.dart';
import '../export/export_controller.dart';
import '../providers/debt_providers.dart';

class ExportBottomSheet extends ConsumerWidget {
  const ExportBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(debtEntriesProvider).maybeWhen(
          data: (data) => data,
          orElse: () => <DebtEntry>[],
        );
    final controller = ref.watch(exportControllerProvider);
    final isEmpty = entries.isEmpty;

    Future<void> run(Future<String> Function() task, String label, {bool showShare = false}) async {
      if (isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada data untuk diekspor')),
          );
        }
        return;
      }
      
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        final path = await task();
        if (!context.mounted) return;
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label tersimpan'),
            action: showShare
                ? SnackBarAction(
                    label: 'Bagikan',
                    onPressed: () => controller.shareFileToWhatsApp(path),
                  )
                : null,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ekspor & Bagikan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('Ekspor ke Excel'),
              subtitle: const Text('Simpan sebagai file .xlsx'),
              onTap: () => run(
                () => controller.exportExcel(List.from(entries)),
                'Excel',
                showShare: true,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Ekspor ke PDF'),
              subtitle: const Text('Simpan sebagai file .pdf'),
              onTap: () => run(
                () => controller.exportPdf(List.from(entries)),
                'PDF',
                showShare: true,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Struk gambar Ara Shop'),
              subtitle: const Text('Gambar struk dengan watermark'),
              onTap: () => run(
                () => controller.exportReceipt(List.from(entries)),
                'Struk',
                showShare: true,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan teks ke WhatsApp'),
              subtitle: const Text('Bagikan ringkasan sebagai teks'),
              onTap: () async {
                if (isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Belum ada data untuk dibagikan')),
                    );
                  }
                  return;
                }
                await controller.shareText(List.from(entries));
              },
            ),
          ],
        ),
      ),
    );
  }
}

