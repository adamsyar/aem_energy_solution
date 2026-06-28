part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.notificationsEnabled = true,
    this.isDarkMode = false,
  });

  final bool notificationsEnabled;
  final bool isDarkMode;

  SettingsState copyWith({bool? notificationsEnabled, bool? isDarkMode}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, isDarkMode];
}
