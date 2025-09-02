// ignore_for_file: deprecated_member_use, use_build_context_synchronously, non_constant_identifier_names

import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:jurisolutions/models/versenha.dart';
import 'package:jurisolutions/navegacao/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jurisolutions/navegacao/reset_senha.dart';

bool _carregando = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

AutenticacaoServicos _Auten = AutenticacaoServicos();

class _LoginPageState extends State<LoginPage> {
  bool queroEntrar = true;
  final _formkey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                kIsWeb
                    ? Container(
                      constraints: const BoxConstraints(maxWidth: 500),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final double imageSize = isMobile ? 200 : 300;
    final double inputFontSize = isMobile ? 18 : 22;
    final double buttonFontSize = isMobile ? 21 : 24;
    final double buttonWidth = isMobile ? 280 : 320;
    final double buttonHeight = isMobile ? 55 : 65;

    return Form(
      key: _formkey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/LogoTelaLogin.png',
            width: imageSize,
            height: imageSize,
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "O e-mail não pode ser vazio.";
              }
              if (value.length < 5) {
                return "O e-mail é muito curto";
              }
              return null;
            },
            style: TextStyle(
              fontSize: inputFontSize,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(label: 'E-mail', icon: Icons.email),
          ),
          const SizedBox(height: 25),

          CampoSenha(
            controller: _senhaController,
            hintText: "Senha",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "A senha não pode ser vazia.";
              }
              if (value.length < 5) {
                return "A senha é muito curta";
              }
              return null;
            },
            decoration: _inputDecoration(label: 'Senha', icon: Icons.lock),
          ),

          const SizedBox(height: 45),

          ElevatedButton(
            onPressed: _carregando ? null : botaoPrincipalClicado,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 55),
              elevation: 4,
              shadowColor: const Color.fromARGB(255, 64, 27, 39),
              backgroundColor: const Color(0xff5E293B),
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
                      "Login",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),

          const SizedBox(height: 25),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResetPass()),
              );
            },
            child: Text(
              "Esqueci minha senha",
              style: TextStyle(
                fontSize: inputFontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 69, 68, 68),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
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

  Future<void> botaoPrincipalClicado() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (_formkey.currentState!.validate()) {
      setState(() => _carregando = true);
      if (queroEntrar) {
        final erro = await _Auten.logarUsuarios(email: email, senha: senha);
        if (erro != null) {
          mostrarSnackBar(context: context, texto: erro);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
      setState(() => _carregando = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
    }
  }
}
