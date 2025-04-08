// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();

  final _auten = AutenticacaoServicos();

  InputDecoration meuInputDecoration(String label, IconData icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
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
        borderSide: const BorderSide(color: Color.fromARGB(255, 181, 164, 150), width: 2),
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
      appBar: AppBar(title: const Text("Cadastro")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: kIsWeb
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

          TextFormField(
            controller: _nomeController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O nome não pode ser vazio.";
              if (value!.length < 5) return "O nome é muito curto";
              return null;
            },
            style: const TextStyle(fontSize: 18),
            decoration: meuInputDecoration("Nome", Icons.account_box),
          ),
          const SizedBox(height: 25),

          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O e-mail não pode ser vazio.";
              if (!value!.contains("@")) return "E-mail inválido";
              return null;
            },
            style: const TextStyle(fontSize: 18),
            decoration: meuInputDecoration("E-mail", Icons.email),
          ),
          const SizedBox(height: 25),

          TextFormField(
            controller: _telefoneController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O telefone não pode ser vazio.";
              return null;
            },
            style: const TextStyle(fontSize: 18),
            decoration: meuInputDecoration("Telefone", Icons.call),
          ),
          const SizedBox(height: 25),

          TextFormField(
            controller: _cpfController,
            validator: (value) {
              if (value?.isEmpty ?? true) return "O CPF/CNPJ não pode ser vazio.";
              if (value!.length < 11) return "Digite um CPF/CNPJ válido";
              return null;
            },
            style: const TextStyle(fontSize: 18),
            decoration: meuInputDecoration("CPF/CNPJ", Icons.feed),
          ),
          const SizedBox(height: 25),

          TextFormField(
            controller: _senhaController,
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return "A senha não pode ser vazia.";
              if (value!.length < 6) return "A senha deve ter pelo menos 6 caracteres";
              return null;
            },
            style: const TextStyle(fontSize: 18),
            decoration: meuInputDecoration("Senha", Icons.lock),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: botaoPrincipalClicado,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 55),
              elevation: 4,
              shadowColor: const Color.fromARGB(255, 64, 27, 39),
              backgroundColor: const Color(0xff5E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text(
              "Me cadastrar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void botaoPrincipalClicado() {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final telefone = _telefoneController.text.trim();
      final cpf = _cpfController.text.trim();
      final senha = _senhaController.text.trim();

      _auten.cadastroUsuario(
        nome: nome,
        email: email,
        telefone: telefone,
        cpf: cpf,
        senha: senha,
      ).then((String? erro) {
        if (erro != null) {
          mostrarSnackBar(context: context, texto: erro);
        } else {
          mostrarSnackBar(context: context, texto: "Cadastro feito com sucesso!");
          _formKey.currentState!.reset();
          _nomeController.clear();
          _emailController.clear();
          _telefoneController.clear();
          _cpfController.clear();
          _senhaController.clear();
        }
      });
    } else {
      mostrarSnackBar(context: context, texto: "Por favor, preencha todos os campos corretamente.");
    }
  }
}
