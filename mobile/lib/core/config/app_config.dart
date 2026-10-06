/// Build-time configuration so each organization can brand and connect the app
/// without touching the source code.
///
/// Values are read from `--dart-define` / `--dart-define-from-file`, e.g.:
///   flutter run --dart-define-from-file=config/app.json
class AppConfig {
  AppConfig._();

  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'Community Attendance');

  /// Short text under the logo on the public home screen. Empty hides it.
  static const String tagline = String.fromEnvironment('APP_TAGLINE', defaultValue: 'Registro de asistencia');

  /// Optional quote at the bottom of the public home screen. Empty hides it.
  static const String slogan = String.fromEnvironment('APP_SLOGAN');

  /// Logo shown on light backgrounds. Either a bundled asset path
  /// (e.g. `assets/branding/logo.png`) or an http(s) URL. Empty shows a
  /// generic icon with [appName].
  static const String logo = String.fromEnvironment('APP_LOGO');

  /// Optional logo for dark backgrounds (public home). Falls back to [logo].
  static const String logoOnDark = String.fromEnvironment('APP_LOGO_ON_DARK');

  // Android Emulator -> local PC backend: http://10.0.2.2:8000.
  // For a physical device use your PC LAN IP, e.g. http://192.168.1.20:8000.
  // Production must use HTTPS, e.g. https://api.example.org.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');
}
