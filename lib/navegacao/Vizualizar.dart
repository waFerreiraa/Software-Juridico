// ignore: file_names
import 'package:flutter/material.dart';

class DetalhesProcessoScreen extends StatelessWidget {
  final String numero;
  final String nomeCliente;
  final String historico;

  const DetalhesProcessoScreen({
    super.key,
    required this.numero,
    required this.nomeCliente,
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    // Pegando o tema atual para cores do corpo da tela
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Cores fixas do AppBar
    final Color appBarColor = const Color(0xFF490A1D); // fixa
    const Color appBarTextColor = Colors.white; // fixa

    // Cores do corpo da tela (respeitando modo escuro)
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final bodyTextBoldColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Processo',
          style: TextStyle(color: appBarTextColor),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número do Caso:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: bodyTextBoldColor,
              ),
            ),
            Text(
              numero,
              style: TextStyle(
                fontSize: 16,
                color: bodyTextColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nome do Cliente:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: bodyTextBoldColor,
              ),
            ),
            Text(
              nomeCliente,
              style: TextStyle(
                fontSize: 16,
                color: bodyTextColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Histórico:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: bodyTextBoldColor,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  historico,
                  style: TextStyle(
                    fontSize: 16,
                    color: bodyTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
