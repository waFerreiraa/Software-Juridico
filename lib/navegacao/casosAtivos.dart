// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:jurisolutions/navegacao/Vizualizar.dart'; 
import 'package:jurisolutions/navegacao/editarinfo.dart';

class CasosAtivos extends StatefulWidget {
  const CasosAtivos({super.key});

  @override
  State<CasosAtivos> createState() => _CasosAtivosState();
}

class _CasosAtivosState extends State<CasosAtivos> {
  final String usuarioId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _excluirProcesso(String processoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('processos')
          .doc(processoId)
          .delete();
      mostrarSnackBar(
        context: context,
        texto: 'Processo excluído com sucesso',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      mostrarSnackBar(
        context: context,
        texto: 'Erro ao excluir processo: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // Função para pegar apenas o último histórico
  String _obterUltimoHistorico(String? historicoCompleto) {
    if (historicoCompleto == null || historicoCompleto.trim().isEmpty) {
      return 'Sem histórico';
    }

    // Divide o histórico por quebras de linha duplas
    final entradas = historicoCompleto.split('\n\n');
    
    // Retorna a última entrada (que é a mais recente)
    if (entradas.isNotEmpty) {
      return entradas.last.trim();
    }
    
    return 'Sem histórico';
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tema atual
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela > 700 ? 700.0 : larguraTela * 0.95;

    // Cores fixas do AppBar
    final Color appBarBgColor = const Color(0xFF490A1D); // fixa
    const Color appBarFgColor = Colors.white; 

    // Cores do restante do app (modo escuro funciona)
    final Color defaultTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color defaultTextBoldColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Casos Ativos',
          style: TextStyle(color: appBarFgColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: appBarBgColor,
        iconTheme: const IconThemeData(color: appBarFgColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('processos')
            .where('usuarioId', isEqualTo: usuarioId)
            .where('status', isEqualTo: 'ativo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum processo ativo.',
                style: TextStyle(color: defaultTextColor),
              ),
            );
          }

          final processosAtivos = snapshot.data!.docs;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: larguraMax),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: processosAtivos.length,
                itemBuilder: (context, index) {
                  final processo =
                      processosAtivos[index].data() as Map<String, dynamic>;
                  final processoId = processosAtivos[index].id;

                  String nomeCliente = 'Não informado';
                  if (processo['partes'] != null &&
                      processo['partes'] is List &&
                      processo['partes'].isNotEmpty) {
                    final partes = List.from(processo['partes']);
                    final primeiraParte = partes[0];
                    if (primeiraParte is Map<String, dynamic> &&
                        primeiraParte.containsKey('nome')) {
                      nomeCliente = primeiraParte['nome'];
                    }
                  }

                  // Pega apenas o último histórico
                  final ultimoHistorico = _obterUltimoHistorico(processo['historico']);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Theme(
                                data: theme,
                                child: DetalhesProcessoScreen(
                                  numero: processo['numero'] ?? 'N/A',
                                  nomeCliente: nomeCliente,
                                  historico: processo['historico'] ??
                                      'Sem histórico disponível',
                                  processoId: processoId,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número: ${processo['numero'] ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: defaultTextBoldColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cliente: $nomeCliente',
                              style: TextStyle(
                                  fontSize: 16, color: defaultTextColor),
                            ),
                            Text(
                              'Último histórico: $ultimoHistorico',
                              style: TextStyle(
                                  fontSize: 16, color: defaultTextColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${processo['status']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: processo['status'] == 'ativo'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: processo['status'] == 'ativo'
                                          ? Colors.green
                                          : Colors.red,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      tooltip: 'Editar processo',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Theme(
                                                data: theme,
                                                child: EditarProcessoScreen(
                                                  processoId: processoId,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Excluir processo',
                                      onPressed: () async {
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Confirmar exclusão',
                                              style: TextStyle(
                                                  color: defaultTextBoldColor),
                                            ),
                                            content: Text(
                                              'Tem certeza que deseja excluir este processo?',
                                              style: TextStyle(
                                                  color: defaultTextColor),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('Excluir'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmar == true) {
                                          await _excluirProcesso(processoId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}