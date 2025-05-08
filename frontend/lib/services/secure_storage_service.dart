import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      await _storage.write(key: 'token', value: token);

  Future<String?> getToken() async => await _storage.read(key: 'token');

  Future<void> deleteToken() async => await _storage.delete(key: 'token');

  // userId 저장 관련
  Future<void> saveUserId(int userId) async =>
      await _storage.write(key: 'userId', value: userId.toString());

  Future<int?> getUserId() async {
    final id = await _storage.read(key: 'userId');
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> deleteUserId() async => await _storage.delete(key: 'userId');
}
