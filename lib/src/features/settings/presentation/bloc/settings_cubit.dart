import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/app_storage.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this._storage}) : super(const SettingsState());

  final AppStorage _storage;

  void loadPreferences() {
    emit(
      state.copyWith(
        notificationsEnabled: _storage.readNotificationsEnabled(),
        isDarkMode: _storage.readDarkModeEnabled(),
      ),
    );
  }

  Future<void> toggleNotifications(bool value) async {
    await _storage.writeNotificationsEnabled(value);
    emit(state.copyWith(notificationsEnabled: value));
  }

  Future<void> toggleDarkMode(bool value) async {
    await _storage.writeDarkModeEnabled(value);
    emit(state.copyWith(isDarkMode: value));
  }
}
