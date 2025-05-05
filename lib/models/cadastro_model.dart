import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServicos {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Cadastra o usuário com e-mail, senha e nome
  Future<String?> cadastroUsuario({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
  }) async {
    if (senha != confirmarSenha) {
      return "As senhas não coincidem";
    }

    try {
      // Cria o usuário
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);

      // Atualiza o nome do usuário
      await userCredential.user!.updateDisplayName(nome);
      await userCredential.user!.reload(); // Garante atualização imediata

      // Desloga o usuário após o cadastro
      await _firebaseAuth.signOut();

      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O usuário já está cadastrado";
      }
      return "Erro ao cadastrar: ${e.message}";
    } catch (e) {
      return "Erro inesperado: $e";
    }
  }

  /// Faz login com e-mail e senha
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

  /// Envia e-mail de redefinição de senha
  Future<String?> resetarSenhaUsu({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "E-mail de redefinição enviado com sucesso.";
    } on FirebaseAuthException catch (e) {
      return 'Erro ao enviar e-mail: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  /// Desloga o usuário atual
  Future<void> deslogar() async {
    await _firebaseAuth.signOut();
  }
}
