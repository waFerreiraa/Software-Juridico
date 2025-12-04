// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';

class DetalhesProcessoScreen extends StatefulWidget {
  final String numero;
  final String nomeCliente;
  final String historico;
  final String? processoId;

  const DetalhesProcessoScreen({
    super.key,
    required this.numero,
    required this.nomeCliente,
    required this.historico,
    this.processoId,
  });

  @override
  State<DetalhesProcessoScreen> createState() => _DetalhesProcessoScreenState();
}

class _DetalhesProcessoScreenState extends State<DetalhesProcessoScreen> {
  String _historicoAtual = '';

  @override
  void initState() {
    super.initState();
    _historicoAtual = widget.historico;
  }

  Future<void> _abrirHistoricoCompleto() async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text(
                'Histórico Completo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFF490A1D),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: _historicoAtual.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: bodyTextColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum histórico adicionado',
                          style: TextStyle(
                            fontSize: 16,
                            color: bodyTextColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _historicoAtual,
                      style: TextStyle(
                        fontSize: 16,
                        color: bodyTextColor,
                        height: 1.8,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _adicionarHistorico() async {
    final TextEditingController historicoController = TextEditingController();
    DateTime dataSelecionada = DateTime.now();

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Adicionar ao Histórico',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: const Color(0xFF490A1D),
                                  onPrimary: Colors.white,
                                  surface: theme.cardColor,
                                  onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        
                        if (pickedDate != null) {
                          setStateDialog(() {
                            dataSelecionada = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF490A1D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF490A1D).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Color(0xFF490A1D),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Data: ${DateFormat('dd/MM/yy').format(dataSelecionada)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF490A1D),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: historicoController,
                      maxLines: 4,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite o histórico...',
                        hintStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : const Color(0xFFE0D3CA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF490A1D),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (historicoController.text.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'texto': historicoController.text.trim(),
                        'data': dataSelecionada,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF490A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null && widget.processoId != null) {
      await _salvarHistorico(resultado['texto'], resultado['data']);
    }
  }

  Future<void> _salvarHistorico(String novoTexto, DateTime data) async {
    try {
      final dataFormatada = DateFormat('dd/MM/yy').format(data);
      final novaEntrada = '$dataFormatada - $novoTexto';
      
      final historicoAtualizado = _historicoAtual.isEmpty
          ? novaEntrada
          : '$novaEntrada\n\n$_historicoAtual';

      await FirebaseFirestore.instance
          .collection('processos')
          .doc(widget.processoId)
          .update({'historico': historicoAtualizado});

      setState(() {
        _historicoAtual = historicoAtualizado;
      });

      mostrarSnackBar(
        context: context,
        texto: 'Histórico atualizado com sucesso!',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      mostrarSnackBar(
        context: context,
        texto: 'Erro ao atualizar histórico: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    const Color appBarColor = Color(0xFF490A1D);
    const Color appBarTextColor = Colors.white;

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
            _buildInfoCard(
              context: context,
              icon: Icons.gavel,
              title: 'Número do Caso',
              content: widget.numero,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context: context,
              icon: Icons.person,
              title: 'Nome do Cliente',
              content: widget.nomeCliente,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildHistoricoCard(
              context: context,
              historico: _historicoAtual,
              iconColor: iconColor,
              cardColor: cardColor,
              textColor: bodyTextColor,
              titleColor: bodyTextBoldColor,
              isDarkMode: isDarkMode,
            ),
            if (widget.processoId != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _adicionarHistorico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF490A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Adicionar Histórico',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
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
    return InkWell(
      onTap: _abrirHistoricoCompleto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                Expanded(
                  child: Text(
                    'Histórico',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: titleColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.fullscreen,
                  color: iconColor.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(
                minHeight: 80,
                maxHeight: 250,
              ),
              child: historico.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: textColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum histórico adicionado',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
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
      ),
    );
  }
}