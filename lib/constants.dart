import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Base URL
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://laporin-be-724441751884.asia-southeast2.run.app';

  // Google OAuth Client IDs
  static String get webClientId => dotenv.env['WEB_CLIENT'] ?? '';
  static String get iosClientId => dotenv.env['IOS_CLIENT'] ?? '';
  static String get androidClientId => dotenv.env['ANDROID_CLIENT'] ?? '';

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
