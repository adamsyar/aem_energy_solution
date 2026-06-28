import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage(this._preferences);

  final SharedPreferences _preferences;

  static const _notificationsKey = 'notifications_enabled';
  static const _darkModeKey = 'dark_mode_enabled';

  bool readNotificationsEnabled() =>
      _preferences.getBool(_notificationsKey) ?? true;

  Future<void> writeNotificationsEnabled(bool value) =>
      _preferences.setBool(_notificationsKey, value);

  bool readDarkModeEnabled() => _preferences.getBool(_darkModeKey) ?? false;

  Future<void> writeDarkModeEnabled(bool value) =>
      _preferences.setBool(_darkModeKey, value);
}
