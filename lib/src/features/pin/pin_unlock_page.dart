import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/app_mode.dart';
import '../../core/providers/app_mode_provider.dart';
import '../../data/services/pin_service_provider.dart';

class PinUnlockPage extends ConsumerStatefulWidget {
  const PinUnlockPage({super.key});

  @override
  ConsumerState<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends ConsumerState<PinUnlockPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final pinService = ref.read(pinServiceProvider);
    final success = await pinService.verify(_pinController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!success) {
      setState(() => _error = 'PIN salah, coba lagi ya.');
      return;
    }
    ref.read(activeModeProvider.notifier).state = AppMode.user;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masukkan PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Selamat datang kembali di MyTagiheun!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Masukkan PIN untuk membuka catatan hutangmu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _pinController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                  ),
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return 'PIN harus 6 digit';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open),
                  label: const Text('Masuk Sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

