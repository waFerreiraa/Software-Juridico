// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:jurisolutions/models/versenha.dart';
import 'package:jurisolutions/navegacao/login.dart';
import 'package:jurisolutions/navegacao/home.dart';

bool _carregando = false;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _auten = AutenticacaoServicos();
  
  // Controla se as dicas de senha estão visíveis
  bool _mostrarDicasSenha = false;

  @override
  void initState() {
    super.initState();
    // Adiciona listener para atualizar em tempo real
    _senhaController.addListener(() {
      if (_mostrarDicasSenha) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // Função para validar senha forte
  String? _validarSenhaForte(String? value) {
    if (value == null || value.isEmpty) {
      return "A senha não pode ser vazia";
    }
    
    if (value.length < 8) {
      return "A senha deve ter pelo menos 8 caracteres";
    }
    
    // Verifica se tem letra maiúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "A senha deve conter pelo menos uma letra maiúscula";
    }
    
    // Verifica se tem letra minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return "A senha deve conter pelo menos uma letra minúscula";
    }
    
    // Verifica se tem número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "A senha deve conter pelo menos um número";
    }
    
    // Verifica se tem caractere especial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "A senha deve conter pelo menos um caractere especial (!@#\$%^&*...)";
    }
    
    return null;
  }

  // Widget para mostrar cada requisito com check verde ou X vermelho
  Widget _buildRequisitoItem(String texto, bool cumprido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            cumprido ? Icons.check_circle : Icons.cancel,
            color: cumprido ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                color: cumprido ? Colors.green[700] : Colors.red[700],
                fontWeight: cumprido ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration meuInputDecoration(String label, IconData icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 13.0,
        horizontal: 10.0,
      ),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xffE0D3CA),
      labelText: label,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 132, 114, 102),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 181, 164, 150),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffE0D3CA), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cadastro"),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                kIsWeb
                    ? Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildForm(),
                    )
                    : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            "Preencha as informações abaixo",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 38),

          // Nome
          TextFormField(
            controller: _nomeController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O nome não pode ser vazio.";
              if (value!.length < 5) return "O nome é muito curto";
              return null;
            },
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: meuInputDecoration("Nome", Icons.account_box),
          ),
          const SizedBox(height: 25),

          // E-mail
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O e-mail não pode ser vazio.";
              if (!value!.contains("@")) return "E-mail inválido";
              return null;
            },
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: meuInputDecoration("E-mail", Icons.email),
          ),
          const SizedBox(height: 25),

          // Senha com validação forte e tooltip flutuante
          Stack(
            clipBehavior: Clip.none,
            children: [
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _mostrarDicasSenha = hasFocus;
                  });
                },
                child: CampoSenha(
                  controller: _senhaController,
                  hintText: "Senha",
                  validator: _validarSenhaForte,
                  decoration: meuInputDecoration("Senha", Icons.lock),
                ),
              ),
              
              // Tooltip flutuante acima do campo
              if (_mostrarDicasSenha)
                Positioned(
                  bottom: 85,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF490A1D),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF490A1D),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Requisitos da senha:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF490A1D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildRequisitoItem("Mínimo 8 caracteres", _senhaController.text.length >= 8),
                          _buildRequisitoItem("Uma letra maiúscula (A-Z)", _senhaController.text.contains(RegExp(r'[A-Z]'))),
                          _buildRequisitoItem("Uma letra minúscula (a-z)", _senhaController.text.contains(RegExp(r'[a-z]'))),
                          _buildRequisitoItem("Um número (0-9)", _senhaController.text.contains(RegExp(r'[0-9]'))),
                          _buildRequisitoItem("Um caractere especial (!@#\$...)", _senhaController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 25),

          // Confirmar senha
          CampoSenha(
            controller: _confirmarSenhaController,
            hintText: "Confirme sua senha",
            validator: (value) {
              if (value == null || value.isEmpty)
                return "A senha não pode ser vazia";
              if (value != _senhaController.text)
                return "As senhas não coincidem";
              return null;
            },
            decoration: meuInputDecoration("Confirme sua senha", Icons.lock),
          ),
          const SizedBox(height: 30),

          // Botão de cadastro
          ElevatedButton(
            onPressed: _carregando ? null : botaoPrincipalClicado,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(345, 55),
              elevation: 4,
              shadowColor: const Color.fromARGB(255, 64, 27, 39),
              backgroundColor: const Color(0xFF490A1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child:
                _carregando
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 173, 98, 123),
                        strokeWidth: 2.8,
                      ),
                    )
                    : const Text(
                      "Cadastrar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  void botaoPrincipalClicado() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final senha = _senhaController.text.trim();
      final confirmar = _confirmarSenhaController.text.trim();

      final erro = await _auten.cadastroUsuario(
        nome: nome,
        email: email,
        senha: senha,
        confirmarSenha: confirmar,
      );

      setState(() => _carregando = false);

      if (erro != null) {
        mostrarSnackBar(context: context, texto: erro);
      } else {
        mostrarSnackBar(
          context: context,
          texto: "Cadastro feito com sucesso!",
          backgroundColor: Colors.green,
        );
        _formKey.currentState!.reset();
        _nomeController.clear();
        _emailController.clear();
        _senhaController.clear();
        _confirmarSenhaController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      mostrarSnackBar(
        context: context,
        texto: "Por favor, preencha todos os campos corretamente.",
      );
    }
  }
}