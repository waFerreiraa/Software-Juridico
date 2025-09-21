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
    // Pegando as cores do tema atual
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Define a cor de fundo do AppBar com base no tema
    final appBarColor = isDarkMode ? theme.cardColor : const Color(0xFF490A1D);
    
    // Define a cor do texto do AppBar com base no tema
    final appBarTextColor = isDarkMode ? Colors.white : Colors.white;

    // Define a cor do texto do corpo da tela com base no tema
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final bodyTextBoldColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
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