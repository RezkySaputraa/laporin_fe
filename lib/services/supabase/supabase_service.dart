import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabaseConnect = Supabase.instance.client;

  Future<AuthResponse> signInWithGoogle(String idToken, String accessToken) {
    return supabaseConnect.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
