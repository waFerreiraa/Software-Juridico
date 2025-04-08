import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServicos {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

Future<String?> cadastroUsuario({
  required String nome,
  required String email,
  required String telefone,
  required String cpf,
  required String senha,
}) async {
  try {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: senha);

    await userCredential.user!.updateDisplayName(nome);

    // DESLOGAR após o cadastro para evitar login automático
    await _firebaseAuth.signOut();

    return null;
  } on FirebaseAuthException catch (e) {
    if (e.code == "email-already-in-use") {
      return ("O usuário já está cadastrado");
    }
    return "Erro desconhecido";
  }
}


  Future<String?> logarUsuarios({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'E-mail não encontrado. Verifique e tente novamente.';
        case 'wrong-password':
          return 'Senha incorreta. Tente novamente.';
        case 'invalid-email':
          return 'Formato de e-mail inválido.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        default:
          return 'Erro ao fazer login: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  Future<void> deslogar()async{
    return _firebaseAuth.signOut();
  }
}
