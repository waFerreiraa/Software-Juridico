import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CasosVencidos extends StatefulWidget {
  const CasosVencidos({super.key});

  @override
  State<CasosVencidos> createState() => _CasosVencidosState();
}

class _CasosVencidosState extends State<CasosVencidos> {
  final String usuarioId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela > 700 ? 700.0 : larguraTela * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
        'Casos Vencidos',
          style: TextStyle(
          color: Colors.white, // título em branco
          fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D), // fundo na cor do app
        iconTheme: const IconThemeData(color: Colors.white), // botão voltar em branco
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('processos')
                .where('usuarioId', isEqualTo: usuarioId)
                .where('status', isEqualTo: 'ativo')
                .where('dataTimestamp', isLessThan: Timestamp.now())
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum processo vencido.'));
          }

          final processosVencidos = snapshot.data!.docs;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: larguraMax),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: processosVencidos.length,
                itemBuilder: (context, index) {
                  final processo =
                      processosVencidos[index].data() as Map<String, dynamic>;
                  final processoId = processosVencidos[index].id;

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
                        // Aqui você pode abrir a tela de detalhes, se quiser
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
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
                                  Text('Cliente: $nomeCliente'),
                                  const SizedBox(height: 8),
                                  Text('Data: ${processo['data'] ?? "N/A"}'),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 32,
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
