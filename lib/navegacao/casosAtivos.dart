// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jurisolutions/navegacao/editarinfo.dart'; // Ajuste o caminho de importação

class CasosAtivos extends StatefulWidget {
  const CasosAtivos({super.key});

  @override
  State<CasosAtivos> createState() => _CasosAtivosState();
}

class _CasosAtivosState extends State<CasosAtivos> {
  final String usuarioId = FirebaseAuth.instance.currentUser!.uid; // Pega o ID do usuário logado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
    'Casos Ativos',
    style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff5E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Filtra os processos pelo usuarioId
        stream: FirebaseFirestore.instance
            .collection('processos')
            .where('usuarioId', isEqualTo: usuarioId)  // Adiciona o filtro
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

          return ListView.builder(
            itemCount: processosAtivos.length,
            itemBuilder: (context, index) {
              final processo = processosAtivos[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text('Número: ${processo['numero']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vara: ${processo['vara']}'),
                      Text('Tribunal: ${processo['tribunal']}'),
                      Text('Andamento: ${processo['andamento']}'),
                      Text('Status: ${processo['status']}'),
                    ],
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: processo['status'] == 'ativo' ? Colors.green : Colors.red,
                  ),
                  onTap: () {
                    // Ao clicar no processo, navega para a tela de edição
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarProcessoScreen(
                          processoId: processosAtivos[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
