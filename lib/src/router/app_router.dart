import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/mode_selection_page.dart';
import '../features/pin/pin_setup_page.dart';
import '../features/pin/pin_unlock_page.dart';
import '../features/home/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ModeSelectionPage(),
      ),
      GoRoute(
        path: '/set-pin',
        builder: (context, state) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/unlock-pin',
        builder: (context, state) => const PinUnlockPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});

