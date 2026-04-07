import 'package:google_sign_in/google_sign_in.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';

class AuthService {
  //WEB CLIENT ID
  static const String _webClientId = "293241377764-4ipsi5achpqcsku9o6ug7vrh0shv60v8.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );
  final UserAPIService _api = UserAPIService();
  final SessionManager _session = SessionManager();

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('No idToken from Google');

      final authResponse = await _api.authWithGoogle(idToken);
      await _session.setAuthenticatedSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.userId,
      );
      return true;
    } catch (e) {
      print('Google Sign-In error: $e');
      return false;
    }
  }

  Future<bool> refreshSession() async {
    final refreshToken = _session.refreshToken;
    if (refreshToken == null) return false;
    try {
      final newTokens = await _api.refreshTokens(refreshToken);
      await _session.updateAccessToken(newTokens.accessToken);
      return true;
    } catch (e) {
      print('Refresh failed: $e');
      await _session.setGuestSession();
      return false;
    }
  }

  Future<void> signOut() async {
    final token = _session.accessToken;
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (e) {
        print('Logout API error: $e');
      }
    }
    await _googleSignIn.signOut();
    await _session.setGuestSession();
  }
}