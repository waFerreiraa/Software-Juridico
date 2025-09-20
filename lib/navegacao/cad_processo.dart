// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Processo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CadPro(),
    );
  }
}

class CadPro extends StatefulWidget {
  const CadPro({super.key});

  @override
  State<CadPro> createState() => _CadProState();
}

class _CadProState extends State<CadPro> {
  int _currentStep = 0;

  // Controllers
  final numeroCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final faseCtrl = TextEditingController();
  final assuntoCtrl = TextEditingController();
  final historicoCtrl = TextEditingController();

  final nomeParteCtrl = TextEditingController();
  final cpfCnpjCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final advogadoCtrl = TextEditingController();
  final oabCtrl = TextEditingController();

  // Dropdown selecionados
  String? _selectedVara;
  String? _selectedTribunal;
  String? _selectedJuizado;
  String? _selectedAndamento;

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

  String? fcmToken;

  // Listas de opções
  final List<String> _varas = [
    '1ª Vara Cível',
    '2ª Vara Cível',
    '3ª Vara Cível',
    'Vara do Juizado Especial Cível',
  ];

  final List<String> _tribunais = ['TJSP', 'TRF-3'];

  final List<String> _juizados = [
    'Juizado Especial Cível',
    'Juizado Especial da Fazenda Pública',
    'Juizado Especial Criminal',
  ];

  final List<String> _andamentos = [
    'Aguardando sentença',
    'Em fase de instrução',
    'Em fase de conciliação',
    'Sentença proferida',
    'Em fase de execução',
  ];

  @override
  void initState() {
    super.initState();
    _initFCMToken();
  }

  Future<void> _initFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      setState(() => fcmToken = newToken);
    });
  }

  InputDecoration meuInputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
    try {
      DateTime dataConvertida = DateFormat('dd/MM/yyyy').parse(dataCtrl.text);

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
        'dataTimestamp': Timestamp.fromDate(dataConvertida),
        'valor':
            double.tryParse(
              valorCtrl.text
                  .replaceAll(RegExp(r'[^0-9,]'), '')
                  .replaceAll(',', '.'),
            ) ??
            0.0,
        'vara': _selectedVara,
        'tribunal': _selectedTribunal,
        'juizado': _selectedJuizado,
        'andamento': _selectedAndamento,
        'fase_processual': faseCtrl.text,
        'assunto': assuntoCtrl.text,
        'historico': historicoCtrl.text,
        'partes': partes,
        'status': 'ativo',
        'usuarioId': FirebaseAuth.instance.currentUser!.uid,
        'token': fcmToken,
        'notificado': false,
      };

      await FirebaseFirestore.instance.collection('processos').add(dados);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processo salvo com sucesso!')),
      );

      _limparCampos();
      setState(() {
        _currentStep = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar processo: $e')));
    }
  }

  void _limparCampos() {
    numeroCtrl.clear();
    dataCtrl.clear();
    valorCtrl.clear();
    faseCtrl.clear();
    assuntoCtrl.clear();
    historicoCtrl.clear();
    nomeParteCtrl.clear();
    cpfCnpjCtrl.clear();
    enderecoCtrl.clear();
    advogadoCtrl.clear();
    oabCtrl.clear();
    _selectedVara = null;
    _selectedTribunal = null;
    _selectedJuizado = null;
    _selectedAndamento = null;
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: meuInputDecoration(label),
      icon: const Icon(Icons.arrow_drop_down), // mantém setinha
      isExpanded: true,
      items:
          options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFormStep1() {
    return Column(
      children: [
        TextFormField(
          controller: numeroCtrl,
          inputFormatters: [numeroProcessoFormatter],
          keyboardType: TextInputType.number,
          decoration: meuInputDecoration("Número*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: dataCtrl,
          decoration: meuInputDecoration("Data*"),
          readOnly: true,
          onTap: () => _selecionarData(context),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: valorCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [valorFormatter],
          decoration: meuInputDecoration("Valor*"),
        ),
        const SizedBox(height: 16),
        _buildDropdownField("Vara*", _selectedVara, _varas, (v) {
          setState(() => _selectedVara = v);
        }),
        const SizedBox(height: 16),
        _buildDropdownField("Tribunal*", _selectedTribunal, _tribunais, (v) {
          setState(() => _selectedTribunal = v);
        }),
        const SizedBox(height: 16),
        _buildDropdownField("Juizado*", _selectedJuizado, _juizados, (v) {
          setState(() => _selectedJuizado = v);
        }),
        const SizedBox(height: 16),
        _buildDropdownField("Andamento*", _selectedAndamento, _andamentos, (v) {
          setState(() => _selectedAndamento = v);
        }),
        const SizedBox(height: 16),
        TextFormField(
          controller: faseCtrl,
          decoration: meuInputDecoration("Fase Processual*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: assuntoCtrl,
          decoration: meuInputDecoration("Assunto*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: historicoCtrl,
          decoration: meuInputDecoration("Histórico*"),
        ),
      ],
    );
  }

  Widget _buildFormStep2() {
    return Column(
      children: [
        TextFormField(
          controller: nomeParteCtrl,
          decoration: meuInputDecoration("Nome*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: cpfCnpjCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [cpfCnpjFormatter],
          decoration: meuInputDecoration("CPF/CNPJ*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: enderecoCtrl,
          decoration: meuInputDecoration("Endereço*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: advogadoCtrl,
          decoration: meuInputDecoration("Advogado*"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: oabCtrl,
          decoration: meuInputDecoration("OAB*"),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = index == _currentStep;
        bool isCompleted = index < _currentStep;

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isActive
                      ? Colors.blue
                      : isCompleted
                      ? Colors.green
                      : Colors.grey.shade400,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            if (index != 2)
              Container(
                width: 40,
                height: 3,
                color:
                    index < _currentStep ? Colors.green : Colors.grey.shade400,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFormStep1();
      case 1:
        return _buildFormStep2();
      default:
        return const Center(
          child: Text(
            "Resumo Final do Processo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Processo"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 30),
              _buildCurrentStep(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: const Text("Voltar"),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 2) {
                          salvarNoFirestore();
                        } else {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      },
                      child: Text(
                        _currentStep == 2 ? "Salvar" : "Próximo passo",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
