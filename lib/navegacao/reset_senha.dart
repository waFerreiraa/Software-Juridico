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
      appBar: AppBar(title: Text("Reset Password")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Coloque seu e-mail, para poder resetar a sua senha.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "O e-mail não pode ser vazio.";
                    }
                    if (!value!.contains("@")) return "E-mail inválido";
                    return null;
                  },
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  decoration: meuInputDecoration("E-mail", Icons.email),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 220,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : botaoPrincipalClicado,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(10, 40),
                      elevation: 4,
                      shadowColor: const Color.fromARGB(255, 79, 30, 46),
                      backgroundColor: const Color(0xff5E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(
                      "Enviar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

      if (erro != null) {
        mostrarSnackBar(context: context, texto: erro);
      } else {
        mostrarSnackBar(
          context: context,
          texto: "Um link para a redefinição de senha foi enviado para seu E-mail!",
          backgroundColor: Colors.green,
        );
        _formKey.currentState!.reset();
        _emailController.clear();

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
