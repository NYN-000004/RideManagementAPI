import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token management
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(ApiConstants.keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(ApiConstants.keyToken);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(ApiConstants.keyToken);
  }

  // User session management
  Future<bool> saveUser(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    return await _prefs.setString(ApiConstants.keyUser, jsonStr);
  }

  UserModel? getUser() {
    final jsonStr = _prefs.getString(ApiConstants.keyUser);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUser() async {
    return await _prefs.remove(ApiConstants.keyUser);
  }

  // Active Role (for Riders who can switch between Rider & Customer modes)
  Future<bool> saveActiveRole(UserRole role) async {
    return await _prefs.setString(ApiConstants.keyActiveRole, role.name);
  }

  UserRole? getActiveRole() {
    final roleStr = _prefs.getString(ApiConstants.keyActiveRole);
    if (roleStr == null) return null;
    return roleStr == UserRole.rider.name ? UserRole.rider : UserRole.customer;
  }

  // Base URL override
  Future<bool> saveBaseUrl(String url) async {
    return await _prefs.setString(ApiConstants.keyBaseUrl, url);
  }

  String getBaseUrl() {
    return _prefs.getString(ApiConstants.keyBaseUrl) ?? ApiConstants.defaultBaseUrl;
  }

  Future<bool> resetBaseUrl() async {
    return await _prefs.remove(ApiConstants.keyBaseUrl);
  }

  // Rider Online Status
  Future<bool> saveRiderOnline(bool isOnline) async {
    return await _prefs.setBool(ApiConstants.keyRiderOnline, isOnline);
  }

  bool getRiderOnline() {
    return _prefs.getBool(ApiConstants.keyRiderOnline) ?? false;
  }

  // Driver Avatar Persistence
  static const String _keyDriverAvatarPrefix = 'nikhy_driver_avatar_';

  Future<bool> saveDriverAvatar(int driverId, String url) async {
    return await _prefs.setString('$_keyDriverAvatarPrefix$driverId', url);
  }

  String? getDriverAvatar(int driverId) {
    return _prefs.getString('$_keyDriverAvatarPrefix$driverId');
  }

  // Full session wipe (on logout or 401)
  Future<void> clearSession() async {
    await _prefs.remove(ApiConstants.keyToken);
    await _prefs.remove(ApiConstants.keyUser);
    await _prefs.remove(ApiConstants.keyActiveRole);
    await _prefs.remove(ApiConstants.keyRiderOnline);
  }
}

