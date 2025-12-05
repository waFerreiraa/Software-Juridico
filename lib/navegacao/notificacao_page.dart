import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacaoPage extends StatelessWidget {
  const NotificacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Erro: usuário não está logado")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('processos')
                .where('usuarioId', isEqualTo: uid) // << FILTRO DO USUÁRIO
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum processo cadastrado"));
          }

          final agora = DateTime.now();
          final docs = snapshot.data!.docs;

          // Filtra os processos que vencem em até 20 dias
          final proximosVencimentos =
              docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['dataTimestamp'] == null) return false;

                final dataVenc = (data['dataTimestamp'] as Timestamp).toDate();
                final diferenca = dataVenc.difference(agora).inDays;

                return diferenca <= 20 && diferenca >= 0;
              }).toList();

          proximosVencimentos.sort((a, b) {
            final dataA = (a['dataTimestamp'] as Timestamp).toDate();
            final dataB = (b['dataTimestamp'] as Timestamp).toDate();
            return dataA.compareTo(dataB);
          });

          if (proximosVencimentos.isEmpty) {
            return const Center(
              child: Text("Nenhum processo próximo do vencimento"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: proximosVencimentos.length,
            itemBuilder: (context, index) {
              final data =
                  proximosVencimentos[index].data() as Map<String, dynamic>;
              final numero = data['numero']?.toString() ?? "Sem número";
              final dataVenc = (data['dataTimestamp'] as Timestamp).toDate();
              final diasRestantes = dataVenc.difference(agora).inDays;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 1),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  title: Text(
                    "Processo Nº $numero",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Vence em $diasRestantes dias (${dataVenc.day}/${dataVenc.month}/${dataVenc.year})',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
