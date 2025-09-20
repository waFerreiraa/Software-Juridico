// ignore_for_file: deprecated_member_use, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:jurisolutions/models/versenha.dart';
import 'package:jurisolutions/navegacao/home.dart';
import 'package:jurisolutions/navegacao/reset_senha.dart';
// import 'package:jurisolutions/models/google_login_service copy.dart'; // seu serviço de GoogleLoginService

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
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
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
    final double imageSize = isMobile ? 145 : 280;
    final double inputFontSize = isMobile ? 18 : 22;
    final double buttonHeight = isMobile ? 55 : 65;

    return Form(
      key: _formkey,
      child: Column(
        children: [
          CircleAvatar(
            radius: 80, // metade do tamanho da imagem
            backgroundImage: AssetImage('assets/icon/icon.png'),
          ),

          const SizedBox(height: 55),
          // E-mail
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

          // Senha
          CampoSenha(
            controller: _senhaController,
            hintText: "Senha",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "A senha não pode ser vazia";
              }
              if (value.length < 5) {
                return "A senha é muito curta";
              }
              return null;
            },
            decoration: _inputDecoration(label: 'Senha', icon: Icons.lock),
          ),

          const SizedBox(height: 15),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResetPass()),
              );
            },
            child: Text(
              "Esqueceu a senha?",
              style: TextStyle(
                fontSize: inputFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF490A1D),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Botão de login tradicional
          ElevatedButton(
            onPressed: _carregando ? null : botaoPrincipalClicado,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              elevation: 4,
              shadowColor: const Color.fromARGB(255, 64, 27, 39),
              backgroundColor: const Color(0xFF490A1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 10),

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
        fontSize: 20, // tamanho quando dentro do input
        color: Color.fromARGB(255, 132, 114, 102),
        fontWeight: FontWeight.bold,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 25, // tamanho quando sobe
        color: Color(0xFF490A1D), // cor quando está focado
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
