import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Função para salvar um processo no Firestore
Future<void> salvarInfo(Map<String, dynamic> dadosProcesso) async {
  try {
    // Adiciona o status e o usuário atual
    dadosProcesso['status'] = 'ativo';
    dadosProcesso['usuarioId'] = FirebaseAuth.instance.currentUser!.uid;  // Inclui o usuário atual

    await db.collection('processos').add(dadosProcesso);
    print('Processo salvo com sucesso!');
  } catch (e) {
    print('Erro ao salvar processo: $e');
  }
}

// Função para pegar todos os processos do Firestore
Future<List> pegarInfo() async {
  List processos = [];

  CollectionReference referenceProcessos = db.collection('processos');
  QuerySnapshot queryProcessos = await referenceProcessos.get();

  for (var documento in queryProcessos.docs) {
    processos.add({
      'id': documento.id,
      ...documento.data() as Map<String, dynamic>
    });
  }

  return processos;
}
