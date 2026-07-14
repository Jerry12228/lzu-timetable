import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemePreference(this.storageValue);

  final String storageValue;

  static AppThemePreference fromStorageValue(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class ThemePreferenceStore {
  ThemePreferenceStore({SharedPreferences? preferences})
    : _preferencesFuture = preferences == null
          ? SharedPreferences.getInstance()
          : Future.value(preferences);

  static const storageKey = 'lzu_timetable_theme_mode_v1';

  final Future<SharedPreferences> _preferencesFuture;

  Future<AppThemePreference> load() async {
    final preferences = await _preferencesFuture;
    return AppThemePreference.fromStorageValue(
      preferences.getString(storageKey),
    );
  }

  Future<void> save(AppThemePreference preference) async {
    final preferences = await _preferencesFuture;
    await preferences.setString(storageKey, preference.storageValue);
  }
}
