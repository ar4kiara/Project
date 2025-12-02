import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/debt_entry.dart';
import '../../../data/repositories/debt_repository_provider.dart';

class DebtFormSheet extends ConsumerStatefulWidget {
  const DebtFormSheet({super.key, this.existing});

  final DebtEntry? existing;

  @override
  ConsumerState<DebtFormSheet> createState() => _DebtFormSheetState();
}

class _DebtFormSheetState extends ConsumerState<DebtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _dueDate;
  DebtFlowType _flow = DebtFlowType.pinjam;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.contactName;
      _amountController.text = existing.nominal.toString();
      _noteController.text = existing.keterangan ?? '';
      _dueDate = existing.jatuhTempo;
      _flow = existing.flow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = ref.read(debtRepositoryProvider);
    final now = DateTime.now();
    final entry = DebtEntry(
      id: widget.existing?.id ?? const Uuid().v4(),
      contactName: _nameController.text.trim(),
      nominal: int.parse(_amountController.text),
      flow: _flow,
      keterangan: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      jatuhTempo: _dueDate,
      dibuatPada: widget.existing?.dibuatPada ?? now,
      diperbaruiPada: now,
    );
    await repo.save(entry);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existing == null
              ? 'Catatan hutang baru ditambahkan'
              : 'Catatan diperbarui',
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDate: _dueDate ?? now,
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: viewInsets + 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null
                    ? 'Catat Hutang / Bayar'
                    : 'Edit Catatan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SegmentedButton<DebtFlowType>(
                segments: const [
                  ButtonSegment(
                    value: DebtFlowType.pinjam,
                    icon: Icon(Icons.south_west),
                    label: Text('Pinjam'),
                  ),
                  ButtonSegment(
                    value: DebtFlowType.bayar,
                    icon: Icon(Icons.north_east),
                    label: Text('Bayar'),
                  ),
                ],
                selected: {_flow},
                onSelectionChanged: (value) {
                  setState(() => _flow = value.first);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kontak'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Nominal (IDR)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Nominal tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Jatuh Tempo'),
                subtitle: Text(
                  _dueDate == null
                      ? 'Tidak diatur'
                      : DateFormat('dd MMM yyyy').format(_dueDate!),
                ),
                trailing: TextButton(
                  onPressed: _pickDueDate,
                  child: const Text('Atur'),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(widget.existing == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

