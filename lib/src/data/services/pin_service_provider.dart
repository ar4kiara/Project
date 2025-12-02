import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pin_service.dart';

final pinServiceProvider = Provider<PinService>((ref) {
  const storage = FlutterSecureStorage();
  return PinService(storage);
});

