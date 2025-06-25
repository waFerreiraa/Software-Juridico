// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      await FirebaseFirestore.instance.collection('processos').doc(processoId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processo excluído com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir processo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela > 700 ? 700.0 : larguraTela * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Casos Ativos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xff5E293B),
        iconTheme: const IconThemeData(color: Colors.white),
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
            return const Center(child: Text('Nenhum processo ativo.'));
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

                  // Extrair nome do cliente dentro da lista 'partes'
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

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Navegar para a tela de detalhes, passando os dados
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesProcessoScreen(
                              numero: processo['numero'] ?? 'N/A',
                              nomeCliente: nomeCliente,
                              historico: processo['historico'] ??
                                  'Sem histórico disponível',
                            ),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cliente: $nomeCliente',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Histórico: ${processo['historico'] ?? "Sem histórico"}',
                              style: const TextStyle(fontSize: 16),
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
                                      icon:
                                          const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Editar processo',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditarProcessoScreen(
                                              processoId: processoId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Excluir processo',
                                      onPressed: () async {
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Confirmar exclusão'),
                                            content: const Text(
                                                'Tem certeza que deseja excluir este processo?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(true),
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
