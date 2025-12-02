import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/app_mode.dart';

final activeModeProvider = StateProvider<AppMode?>(
  (ref) => null,
  name: 'activeModeProvider',
);

