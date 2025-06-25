// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

enum CadProcesso { geral, partes }

class CadPro extends StatefulWidget {
  const CadPro({super.key});

  @override
  State<CadPro> createState() => _CadProState();
}

class _CadProState extends State<CadPro> {
  CadProcesso cadproView = CadProcesso.geral;

  // Controllers
  final numeroCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final varaCtrl = TextEditingController();
  final tribunalCtrl = TextEditingController();
  final juizadoCtrl = TextEditingController();
  final andamentoCtrl = TextEditingController();
  final faseCtrl = TextEditingController();
  final assuntoCtrl = TextEditingController();
  final historicoCtrl = TextEditingController();

  final nomeParteCtrl = TextEditingController();
  final cpfCnpjCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final advogadoCtrl = TextEditingController();
  final oabCtrl = TextEditingController();

  // Máscaras
  final numeroProcessoFormatter = MaskTextInputFormatter(
    mask: '######-##.####.#.##.####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final dataFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final valorFormatter = CurrencyInputFormatter(
    leadingSymbol: 'R\$',
    useSymbolPadding: true,
  );

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
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
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

  Future<void> _selecionarData(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        dataCtrl.text = DateFormat('dd/MM/yyyy').format(dataSelecionada);
      });
    }
  }

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
      'valor': double.tryParse(
              valorCtrl.text.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.')) ??
          0.0,
      'vara': varaCtrl.text,
      'tribunal': tribunalCtrl.text,
      'juizado': juizadoCtrl.text,
      'andamento': andamentoCtrl.text,
      'fase_processual': faseCtrl.text,
      'assunto': assuntoCtrl.text,
      'historico': historicoCtrl.text,
      'partes': partes,
      'status': 'ativo',
      'usuarioId': FirebaseAuth.instance.currentUser!.uid,
    };

    try {
      await FirebaseFirestore.instance.collection('processos').add(dados);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processo salvo com sucesso!')),
      );
      _limparCampos();
    } catch (e) {
      print('Erro ao salvar processo: $e');
    }
  }

  void _limparCampos() {
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
    historicoCtrl.clear();
  }

  Widget _buildForm(List<String> campos, List<TextEditingController> controllers,
      double largura,
      {List<TextInputFormatter>? formatadores,
      List<TextInputType>? teclados}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: Column(
          children: [
            for (int i = 0; i < campos.length; i++) ...[
              TextFormField(
                controller: controllers[i],
                inputFormatters: formatadores != null ? [formatadores[i]] : null,
                keyboardType: teclados != null ? teclados[i] : TextInputType.text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: meuInputDecoration(campos[i]),
                readOnly: campos[i] == "Data*",
                onTap: campos[i] == "Data*" ? () => _selecionarData(context) : null,
              ),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: salvarNoFirestore,
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
        ),
      ),
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
        "Historico*",
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
        historicoCtrl,
      ],
      largura,
      formatadores: [
        numeroProcessoFormatter,
        dataFormatter,
        valorFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
      ],
      teclados: [
        TextInputType.number,
        TextInputType.datetime,
        TextInputType.number,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
      ],
    );
  }

  Widget _buildPartesEnvolvidas(double largura) {
    return _buildForm(
      ["Nome*", "CPF/CNPJ*", "Endereço*", "Advogado*", "OAB*"],
      [nomeParteCtrl, cpfCnpjCtrl, enderecoCtrl, advogadoCtrl, oabCtrl],
      largura,
      formatadores: [
        FilteringTextInputFormatter.singleLineFormatter,
        cpfCnpjFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.singleLineFormatter,
      ],
      teclados: [
        TextInputType.text,
        TextInputType.number,
        TextInputType.text,
        TextInputType.text,
        TextInputType.text,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela > 600 ? 600.0 : larguraTela * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Cadastro de Processo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Center(
              child: IntrinsicWidth(
                child: SegmentedButton<CadProcesso>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: const Color(0xffE0D3CA),
                    foregroundColor: Colors.black,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: const Color(0xff5E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  segments: const [
                    ButtonSegment<CadProcesso>(
                      value: CadProcesso.geral,
                      label: Text("Informações Gerais",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    ButtonSegment<CadProcesso>(
                      value: CadProcesso.partes,
                      label: Text("Partes Envolvidas",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  if (cadproView == CadProcesso.geral) _buildInformacoesGerais(larguraMax),
                  if (cadproView == CadProcesso.partes) _buildPartesEnvolvidas(larguraMax),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
