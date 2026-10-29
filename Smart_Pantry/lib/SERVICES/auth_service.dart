// lib/SERVICES/auth_service.dart
//
// Local household profile protected by a 4-digit PIN. The PIN is stored as a
// salted SHA-256 hash in the local database, never in plain text.
// NOTE: a 4-digit PIN only keeps casual users out of the household's pantry
// data; it is not strong cryptographic protection, and that is how the
// documentation should describe it.
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:smart_pantry/DATA/database_helper.dart';

class AuthService {
  AuthService._();

  static const _kName = 'profile_name';
  static const _kSalt = 'pin_salt';
  static const _kHash = 'pin_hash';

  static DatabaseHelper get _db => DatabaseHelper.instance;

  static Future<bool> hasProfile() async => (await _db.getSetting(_kHash)) != null;

  static Future<String> displayName() async =>
      (await _db.getSetting(_kName)) ?? 'Household';

  static String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static Future<void> createProfile({
    required String name,
    required String pin,
  }) async {
    final rnd = Random.secure();
    final salt =
        base64UrlEncode(List<int>.generate(16, (_) => rnd.nextInt(256)));
    await _db.setSetting(_kName, name.trim());
    await _db.setSetting(_kSalt, salt);
    await _db.setSetting(_kHash, _hash(pin, salt));
  }

  static Future<bool> verify(String pin) async {
    final salt = await _db.getSetting(_kSalt);
    final hash = await _db.getSetting(_kHash);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  /// Removes the profile/PIN only. Pantry data and history are kept.
  static Future<void> resetProfile() async {
    await _db.deleteSetting(_kName);
    await _db.deleteSetting(_kSalt);
    await _db.deleteSetting(_kHash);
  }
}
