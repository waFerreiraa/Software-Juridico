// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:jurisolutions/models/google_login_service copy.dart';
import 'package:jurisolutions/navegacao/cadastro.dart';
import 'package:jurisolutions/navegacao/home.dart';
import 'package:jurisolutions/navegacao/login.dart';

class InicioTela extends StatefulWidget {
  const InicioTela({super.key});

  @override
  State<InicioTela> createState() => _InicioTelaState();
}

class _InicioTelaState extends State<InicioTela> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
    );
  }

  // 🌐 Layout Web com duas colunas
  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // Lado esquerdo com cor ou imagem
        Expanded(
          child: Container(
            color: const Color(0xFF5E293B),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Image.asset(
                  'assets/Logoxs.png',
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // Lado direito com os botões e textos
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildConteudo(context, isMobile: false),
            ),
          ),
        ),
      ],
    );
  }

  // 📱 Layout Mobile centralizado
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight * 0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/Logoxs.png', height: 180),
              const SizedBox(height: 30),
              _buildConteudo(context, isMobile: true),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🧱 Conteúdo compartilhado entre web/mobile
  Widget _buildConteudo(BuildContext context, {required bool isMobile}) {
    final double buttonHeight = isMobile ? 50 : 60;
    final double fontSize = isMobile ? 20 : 24;
    final double subtitleSize = isMobile ? 16 : 18;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Deixe seu dia a dia mais prático com",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        Text(
          "o nosso aplicativo",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Faça login ou se cadastre de graça!",
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xff6C6C6C),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Botão de cadastro
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CadastroPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF490A1D),
            minimumSize: Size(double.infinity, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          child: const Text(
            "Começar grátis",
            style: TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 20),

        // Botão de login
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE0D3CA),
            foregroundColor: Colors.black87,
            minimumSize: Size(double.infinity, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          child: const Text("Já sou cadastrado"),
        ),

        const SizedBox(height: 25),

        // Texto "Ou faça login com Google"
        Column(
          children: [
            const Text(
              "Ou faça login com o Google",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}
