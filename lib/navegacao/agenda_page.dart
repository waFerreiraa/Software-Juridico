import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginWidget extends StatefulWidget {
  const GoogleLoginWidget({Key? key}) : super(key: key);

  @override
  State<GoogleLoginWidget> createState() => _GoogleLoginWidgetState();
}

class _GoogleLoginWidgetState extends State<GoogleLoginWidget> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/calendar'],
  );

  GoogleSignInAccount? _currentUser;
  String _status = 'Não autenticado';

  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      setState(() {
        _currentUser = account;
        _status =
            account != null
                ? 'Logado como: ${account.email}'
                : 'Login cancelado';
      });
    } catch (error) {
      setState(() {
        _status = 'Erro ao logar: $error';
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _status = 'Desconectado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_status),
        const SizedBox(height: 20),
        if (_currentUser == null)
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('Fazer login com Google'),
          )
        else
          ElevatedButton(onPressed: _handleSignOut, child: const Text('Sair')),
      ],
    );
  }
}
