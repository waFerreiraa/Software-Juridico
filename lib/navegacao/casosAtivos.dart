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
  InputDecoration meuInputDecoration(String label) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 12.0,
      ),
      filled: true,
      fillColor: dark ? Colors.grey[800] : const Color(0xffE0D3CA),

      prefixIcon: const Icon(Icons.search_rounded),
      labelText: label,
      labelStyle: TextStyle(
        color:
            dark ? Colors.grey[300] : const Color.fromARGB(255, 132, 114, 102),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color:
              dark
                  ? Colors.grey[500]!
                  : const Color.fromARGB(255, 181, 164, 150),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: dark ? Colors.grey[700]! : const Color(0xffE0D3CA),
          width: 2,
        ),
      ),
    );
  }

  final usuarioId = FirebaseAuth.instance.currentUser!.uid;

  // Controlador da pesquisa
  TextEditingController pesquisaCtrl = TextEditingController();
  String termoPesquisa = "";

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

  String _obterUltimoHistorico(String? historicoCompleto) {
    if (historicoCompleto == null || historicoCompleto.trim().isEmpty) {
      return 'Sem histórico';
    }

    final entradas = historicoCompleto.split('\n\n');
    if (entradas.isNotEmpty) {
      return entradas.last.trim();
    }

    return 'Sem histórico';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela > 700 ? 700.0 : larguraTela * 0.95;

    final Color appBarBgColor = const Color(0xFF490A1D);
    const Color appBarFgColor = Colors.white;

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

      body: Column(
        children: [
          // 🔍 CAMPO DE PESQUISA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: pesquisaCtrl,
              decoration: meuInputDecoration("Número CNJ"),
              onChanged: (valor) {
                setState(() {
                  termoPesquisa = valor.trim();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
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

                // 🔥 FILTRAR PROCESSOS PELO NÚMERO
                final processosAtivos =
                    snapshot.data!.docs.where((doc) {
                      final processo = doc.data() as Map<String, dynamic>;
                      final numero = (processo['numero'] ?? '').toString();

                      if (termoPesquisa.isEmpty) return true;

                      return numero.contains(termoPesquisa);
                    }).toList();

                if (processosAtivos.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum processo encontrado.',
                      style: TextStyle(color: defaultTextColor),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: larguraMax),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: processosAtivos.length,
                      itemBuilder: (context, index) {
                        final processo =
                            processosAtivos[index].data()
                                as Map<String, dynamic>;
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

                        final ultimoHistorico = _obterUltimoHistorico(
                          processo['historico'],
                        );

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
                                        historico:
                                            processo['historico'] ??
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
                                      fontSize: 16,
                                      color: defaultTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Último histórico: $ultimoHistorico',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: defaultTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Status: ${processo['status']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              processo['status'] == 'ativo'
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color:
                                                processo['status'] == 'ativo'
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                            tooltip: 'Editar processo',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return Theme(
                                                      data: theme,
                                                      child:
                                                          EditarProcessoScreen(
                                                            processoId:
                                                                processoId,
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
                                              final confirmar = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: Text(
                                                        'Confirmar exclusão',
                                                        style: TextStyle(
                                                          color:
                                                              defaultTextBoldColor,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        'Tem certeza que deseja excluir este processo?',
                                                        style: TextStyle(
                                                          color:
                                                              defaultTextColor,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                          child: const Text(
                                                            'Excluir',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirmar == true) {
                                                await _excluirProcesso(
                                                  processoId,
                                                );
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
          ),
        ],
      ),
    );
  }
}
