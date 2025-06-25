import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarProcessoScreen extends StatefulWidget {
  final String processoId;

  const EditarProcessoScreen({super.key, required this.processoId});

  @override
  State<EditarProcessoScreen> createState() => _EditarProcessoScreenState();
}

class _EditarProcessoScreenState extends State<EditarProcessoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController numeroController;
  late TextEditingController varaController;
  late TextEditingController tribunalController;
  late TextEditingController andamentoController;
  late TextEditingController faseController;
  late TextEditingController assuntoController;

  final String usuarioId =
      FirebaseAuth.instance.currentUser!.uid; // Pega o ID do usuário logado

  @override
  void initState() {
    super.initState();

    // Inicializa os controllers
    numeroController = TextEditingController();
    varaController = TextEditingController();
    tribunalController = TextEditingController();
    andamentoController = TextEditingController();
    faseController = TextEditingController();
    assuntoController = TextEditingController();

    // Carregar os dados do processo
    _carregarProcesso();
  }

  Future<void> _carregarProcesso() async {
    DocumentSnapshot processoDoc =
        await FirebaseFirestore.instance
            .collection('processos')
            .doc(widget.processoId)
            .get();

    final processoData = processoDoc.data() as Map<String, dynamic>;

    // Verifica se o processo pertence ao usuário logado
    if (processoData['usuarioId'] == usuarioId) {
      setState(() {
        numeroController.text = processoData['numero'];
        varaController.text = processoData['vara'];
        tribunalController.text = processoData['tribunal'];
        andamentoController.text = processoData['andamento'];
        faseController.text = processoData['fase_processual'];
        assuntoController.text = processoData['assunto'];
      });
    } else {
      // Caso o processo não pertença ao usuário logado, exibe um erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem permissão para editar este processo.'),
        ),
      );
      Navigator.pop(context); // Retorna à tela anterior
    }
  }

  Future<void> _salvarProcesso() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('processos')
          .doc(widget.processoId)
          .update({
            'numero': numeroController.text,
            'vara': varaController.text,
            'tribunal': tribunalController.text,
            'andamento': andamentoController.text,
            'fase_processual': faseController.text,
            'assunto': assuntoController.text,
          });

      // Volta para a tela de Casos Ativos
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Processo'),
        backgroundColor: const Color(0xff5E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: numeroController,
                  decoration: const InputDecoration(labelText: 'Número'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: varaController,
                  decoration: const InputDecoration(labelText: 'Vara'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: tribunalController,
                  decoration: const InputDecoration(labelText: 'Tribunal'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: andamentoController,
                  decoration: const InputDecoration(labelText: 'Andamento'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: faseController,
                  decoration: const InputDecoration(
                    labelText: 'Fase Processual',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: assuntoController,
                  decoration: const InputDecoration(labelText: 'Assunto'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarProcesso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E293B),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
