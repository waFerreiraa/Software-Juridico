import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CadProcesso { geral, partes }

class CadPro extends StatefulWidget {
  const CadPro({super.key});

  @override
  State<CadPro> createState() => _CadProState();
}

class _CadProState extends State<CadPro> {
  CadProcesso cadproView = CadProcesso.geral;

  // Controllers para informações gerais
  final numeroCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final varaCtrl = TextEditingController();
  final tribunalCtrl = TextEditingController();
  final juizadoCtrl = TextEditingController();
  final andamentoCtrl = TextEditingController();
  final faseCtrl = TextEditingController();
  final assuntoCtrl = TextEditingController();

  // Controllers para partes envolvidas (única parte por enquanto)
  final nomeParteCtrl = TextEditingController();
  final cpfCnpjCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final advogadoCtrl = TextEditingController();
  final oabCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  InputDecoration meuInputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 13.0,
        horizontal: 10.0,
      ),
      filled: true,
      fillColor: const Color(0xffE0D3CA),
      labelText: label,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 132, 114, 102),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 181, 164, 150),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffE0D3CA), width: 2),
      ),
    );
  }

  // Função para salvar no Firestore
  Future<void> salvarNoFirestore() async {
    final partes = [
      {
        'nome': nomeParteCtrl.text,
        'cpf_cnpj': cpfCnpjCtrl.text,
        'endereco': enderecoCtrl.text,
        'advogado': advogadoCtrl.text,
        'oab': oabCtrl.text,
      },
    ];

    final dados = {
      'numero': numeroCtrl.text,
      'data': dataCtrl.text,
      'valor': double.tryParse(valorCtrl.text) ?? 0.0,
      'vara': varaCtrl.text,
      'tribunal': tribunalCtrl.text,
      'juizado': juizadoCtrl.text,
      'andamento': andamentoCtrl.text,
      'fase_processual': faseCtrl.text,
      'assunto': assuntoCtrl.text,
      'partes': partes,
      'status': 'ativo',  // Status 'ativo' para todos os processos
    };
    numeroCtrl.clear();
    dataCtrl.clear();
    valorCtrl.clear();
    varaCtrl.clear();
    tribunalCtrl.clear();
    juizadoCtrl.clear();
    andamentoCtrl.clear();
    faseCtrl.clear();
    assuntoCtrl.clear();
    nomeParteCtrl.clear();
    cpfCnpjCtrl.clear();
    enderecoCtrl.clear();
    advogadoCtrl.clear();
    oabCtrl.clear();

    // Chamada da função de salvar no Firestore
    await salvarInfo(dados);

    // Feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processo salvo com sucesso!')),
    );
  }

  // Função para salvar no Firestore
  Future<void> salvarInfo(Map<String, dynamic> dadosProcesso) async {
    try {
      dadosProcesso['usuarioId'] = FirebaseAuth.instance.currentUser!.uid;  // Inclui o usuário logado
      await FirebaseFirestore.instance.collection('processos').add(dadosProcesso);
      print('Processo salvo com sucesso!');
    } catch (e) {
      print('Erro ao salvar processo: $e');
    }
  }

  Widget _buildForm(
    List<String> campos,
    List<TextEditingController> controllers,
    double largura,
  ) {
    return Column(
      children: [
        for (int i = 0; i < campos.length; i++) ...[
          TextFormField(
            controller: controllers[i],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: meuInputDecoration(campos[i]),
          ),
          const SizedBox(height: 30),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: SizedBox(
            width: largura,
            height: 55,
            child: ElevatedButton(
              onPressed: salvarNoFirestore,  // Chamada da função ao pressionar "Salvar"
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shadowColor: const Color.fromARGB(255, 64, 27, 39),
                backgroundColor: const Color(0xff5E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                "Salvar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesGerais(double largura) {
    return _buildForm(
      [
        "Número*",
        "Data*",
        "Valor*",
        "Vara*",
        "Tribunal*",
        "Juizado*",
        "Andamento*",
        "Fase Processual*",
        "Assunto*",
      ],
      [
        numeroCtrl,
        dataCtrl,
        valorCtrl,
        varaCtrl,
        tribunalCtrl,
        juizadoCtrl,
        andamentoCtrl,
        faseCtrl,
        assuntoCtrl,
      ],
      largura,
    );
  }

  Widget _buildPartesEnvolvidas(double largura) {
    return _buildForm(
      ["Nome*", "CPF/CNPJ*", "Endereço*", "Advogado*", "OAB*"],
      [nomeParteCtrl, cpfCnpjCtrl, enderecoCtrl, advogadoCtrl, oabCtrl],
      largura,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax =
        larguraTela * 0.9 > 500 ? 500.0 : larguraTela * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Cadastro de Processo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Center(
              child: IntrinsicWidth(
                child: SegmentedButton<CadProcesso>(  // Alternar entre as views
                  style: SegmentedButton.styleFrom(
                    backgroundColor: const Color(0xffE0D3CA),
                    foregroundColor: Colors.black,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: const Color(0xff5E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  segments: const [
                    ButtonSegment<CadProcesso>(
                      value: CadProcesso.geral,
                      label: Text(
                        'Informações Gerais',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ButtonSegment<CadProcesso>(
                      value: CadProcesso.partes,
                      label: Text(
                        'Partes Envolvidas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  selected: <CadProcesso>{cadproView},
                  onSelectionChanged: (Set<CadProcesso> newSelection) {
                    setState(() {
                      cadproView = newSelection.first;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (cadproView == CadProcesso.geral)
                      _buildInformacoesGerais(larguraMax),
                    if (cadproView == CadProcesso.partes)
                      _buildPartesEnvolvidas(larguraMax),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
