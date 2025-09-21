import 'package:flutter/material.dart';
import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:jurisolutions/navegacao/login.dart';

bool _carregando = false;

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auten = AutenticacaoServicos();

  InputDecoration meuInputDecoration(String label, IconData icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xffE0D3CA),
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromARGB(255, 132, 114, 102),
        fontWeight: FontWeight.bold,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 25,
        color: Color(0xFF490A1D),
        fontWeight: FontWeight.w700,
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
      appBar: AppBar(
        title: const Text(
          "Resetar Senha",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D), // cor do topo
        iconTheme: const IconThemeData(color: Colors.white), // botão voltar branco
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Coloque seu e-mail, para poder resetar a sua senha.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return "O e-mail não pode ser vazio.";
                    if (!value!.contains("@")) return "E-mail inválido";
                    return null;
                  },
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  decoration: meuInputDecoration("E-mail", Icons.email),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : botaoPrincipalClicado,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(10, 40),
                      elevation: 4,
                      shadowColor: const Color.fromARGB(255, 79, 30, 46),
                      backgroundColor: const Color(0xFF490A1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      "Enviar",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void botaoPrincipalClicado() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final email = _emailController.text.trim();
      final erro = await _auten.resetarSenhaUsu(email: email);

      setState(() => _carregando = false);

      mostrarSnackBar(
        context: context,
        texto: erro ?? "Um link para a redefinição de senha foi enviado para seu E-mail!",
        backgroundColor: Colors.green,
      );

      if (erro == null) {
        _formKey.currentState!.reset();
        _emailController.clear();
      }
    } else {
      mostrarSnackBar(
        context: context,
        texto: "Por favor, preencha todos os campos corretamente.",
        backgroundColor: Colors.yellow,
      );
    }
  }
}
