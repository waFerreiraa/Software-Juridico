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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Processo'),
        backgroundColor: const Color(0xff5E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número do Caso:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(numero, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Nome do Cliente:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(nomeCliente, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Histórico:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(historico, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
