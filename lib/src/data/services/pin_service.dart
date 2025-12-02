import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService(this._storage);

  final FlutterSecureStorage _storage;
  static const _pinKey = 'tagiheun_pin_secure';

  Future<bool> hasPin() => _storage.containsKey(key: _pinKey);

  Future<void> savePin(String pin) =>
      _storage.write(key: _pinKey, value: _hash(pin));

  Future<bool> verify(String pin) async {
    final saved = await _storage.read(key: _pinKey);
    if (saved == null) return false;
    return saved == _hash(pin);
  }

  Future<void> remove() => _storage.delete(key: _pinKey);

  String _hash(String input) {
    final bytes = utf8.encode('mytagiheun::$input');
    return sha256.convert(bytes).toString();
  }
}

