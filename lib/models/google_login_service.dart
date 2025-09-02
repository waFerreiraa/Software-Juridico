import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.events', // 🔑 permissão p/ criar, editar e deletar eventos
      'https://www.googleapis.com/auth/calendar.readonly', // 🔑 leitura de eventos
    ],
  );

  GoogleSignInAccount? currentUser;

  GoogleLoginService() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      currentUser = account;
    });
  }

  /// Tenta login silencioso (sem pedir senha novamente se já tiver sessão)
  Future<GoogleSignInAccount?> signInSilently() async {
    currentUser = await _googleSignIn.signInSilently();
    return currentUser;
  }

  /// Login com Google
  Future<GoogleSignInAccount?> signIn() async {
    currentUser = await _googleSignIn.signIn();
    return currentUser;
  }

  /// Logout
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    currentUser = null;
  }

  /// Listener p/ mudanças de usuário
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;
}
