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
    final Color appBarColor = const Color(0xFF490A1D);
    const Color appBarTextColor = Colors.white;

    // Cores do corpo da tela (respeitando modo escuro)
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final bodyTextBoldColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[850] : const Color(0xFFE0D3CA);
    final iconColor = isDarkMode ? const Color(0xFFE0D3CA) : const Color(0xFF490A1D);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Processo',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card - Número do Caso
            _buildInfoCard(
              context: context,
              icon: Icons.gavel,
              title: 'Número do Caso',
              content: numero,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 16),
            
            // Card - Nome do Cliente
            _buildInfoCard(
              context: context,
              icon: Icons.person,
              title: 'Nome do Cliente',
              content: nomeCliente,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 16),
            
            // Card - Histórico (expandido)
            _buildHistoricoCard(
              context: context,
              historico: historico,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    required Color? cardColor,
    required Color textColor,
    required Color titleColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: titleColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricoCard({
    required BuildContext context,
    required String historico,
    required Color iconColor,
    required Color? cardColor,
    required Color textColor,
    required Color titleColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history_edu,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Histórico',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: titleColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: isDarkMode 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Conteúdo do histórico
          Container(
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 400,
            ),
            child: SingleChildScrollView(
              child: Text(
                historico,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}