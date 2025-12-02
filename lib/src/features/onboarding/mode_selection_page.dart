import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/app_mode.dart';
import '../../core/providers/app_mode_provider.dart';
import '../../data/services/pin_service_provider.dart';

class ModeSelectionPage extends ConsumerWidget {
  const ModeSelectionPage({super.key});

  Future<void> _handleUser(BuildContext context, WidgetRef ref) async {
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    if (!context.mounted) return;
    if (hasPin) {
      context.push('/unlock-pin');
    } else {
      context.push('/set-pin');
    }
  }

  Future<void> _handleDeveloper(BuildContext context, WidgetRef ref) async {
    ref.read(activeModeProvider.notifier).state = AppMode.developer;
    if (!context.mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'MyTagiheun',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih mode sesuai kebutuhanmu. Mode Pengguna untuk catatan harian, Mode Pengembang untuk tes data instan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _ModeCard(
                title: 'Menu Pengguna',
                description:
                    'Set PIN pribadi dan simpan data hutang di perangkat secara aman.',
                color: const Color(0xFFF9D7E4),
                icon: Icons.lock,
                onTap: () => _handleUser(context, ref),
              ),
              const SizedBox(height: 24),
              _ModeCard(
                title: 'Menu Pengembang',
                description:
                    'Masuk kilat tanpa PIN. Data akan otomatis lenyap setelah aplikasi ditutup.',
                color: const Color(0xFFE0E7FF),
                icon: Icons.speed,
                onTap: () => _handleDeveloper(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: color,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 32, color: Colors.black87),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

