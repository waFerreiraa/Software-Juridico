import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _carregando = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() => _isLoadingData = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        _nomeController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      mostrarSnackBar(
        context: context,
        texto: 'Erro ao carregar dados: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      mostrarSnackBar(
        context: context,
        texto: 'Por favor, preencha todos os campos corretamente.',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Atualiza o nome de exibição
      if (_nomeController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nomeController.text.trim());
      }

      // Atualiza o email se foi alterado
      if (_emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        
        mostrarSnackBar(
          context: context,
          texto: 'Um email de verificação foi enviado para o novo endereço.',
          type: SnackBarType.info,
        );
      }

      // Recarrega os dados do usuário
      await user.reload();
      
      mostrarSnackBar(
        context: context,
        texto: 'Perfil atualizado com sucesso!',
        backgroundColor: Colors.green,
      );

      // Volta para a tela anterior
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro = 'Erro ao atualizar perfil';
      
      switch (e.code) {
        case 'requires-recent-login':
          mensagemErro = 'Por segurança, faça login novamente antes de alterar o email.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        case 'email-already-in-use':
          mensagemErro = 'Este email já está em uso.';
          break;
        default:
          mensagemErro = 'Erro: ${e.message}';
      }
      
      mostrarSnackBar(
        context: context,
        texto: mensagemErro,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      mostrarSnackBar(
        context: context,
        texto: 'Erro ao atualizar perfil: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  InputDecoration _meuInputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 12.0,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? Colors.white70 : const Color(0xFF490A1D),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : const Color(0xFFE0D3CA),
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : const Color.fromARGB(255, 132, 114, 102),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white54 : const Color.fromARGB(255, 181, 164, 150),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE0D3CA),
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF490A1D)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone de perfil
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF490A1D).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: const Color(0xFF490A1D),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // Campo Nome
                    TextFormField(
                      controller: _nomeController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "O nome não pode ser vazio.";
                        }
                        if (value!.length < 3) {
                          return "O nome deve ter pelo menos 3 caracteres";
                        }
                        return null;
                      },
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: _meuInputDecoration("Nome", Icons.person),
                    ),

                    const SizedBox(height: 20),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "O e-mail não pode ser vazio.";
                        }
                        if (!value!.contains("@")) {
                          return "E-mail inválido";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: _meuInputDecoration("E-mail", Icons.email),
                    ),

                    const SizedBox(height: 30),

                    // Aviso sobre alteração de email
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ao alterar o email, você receberá um link de verificação.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botão Salvar
                    ElevatedButton(
                      onPressed: _carregando ? null : _salvarAlteracoes,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        elevation: 4,
                        shadowColor: const Color.fromARGB(255, 64, 27, 39),
                        backgroundColor: const Color(0xFF490A1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.8,
                              ),
                            )
                          : const Text(
                              "Salvar Alterações",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}