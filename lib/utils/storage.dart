import 'package:get_storage/get_storage.dart';

class Storage {
  final GetStorage _storage = GetStorage();

  void saveToken(String token) => _storage.write("accessToken", token);
  void saveRefreshToken(String token) => _storage.write("refreshToken", token);
  void saveName(String name) => _storage.write("username", name);

  void login() => _storage.write("isLoggedIn", true);
  void logout() => _storage.write("isLoggedIn", false);

  bool get isLoggedIn => _storage.read("isLoggedIn") ?? false;
  String? getToken() => _storage.read<String>("accessToken");
  String? getRefreshToken() => _storage.read<String>("refreshToken");
  String? getName() => _storage.read<String>("username");

}