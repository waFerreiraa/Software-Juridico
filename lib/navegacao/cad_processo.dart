import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final numeroVaraCtrl = TextEditingController();
  final andamentoCtrl = TextEditingController();
  final faseCtrl = TextEditingController();
  final assuntoCtrl = TextEditingController();
  final historicoCtrl = TextEditingController();

  final nomeParteCtrl = TextEditingController();
  final cpfCnpjCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final advogadoCtrl = TextEditingController();
  final oabCtrl = TextEditingController();

  // Variáveis para dropdowns
  String? _selectedVara;
  String? _selectedTribunal;
  String? _selectedJuizado;
  String? _selectedAndamento;
  String? _selectedFase;

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
    'Vara Cível',
    'Vara Criminal',
    'Vara da Família',
    'Vara do Trabalho',
    'Vara da Infância e Juventude',
    'Vara da Fazenda Pública',
    'Vara do Juizado Especial Cível',
  ];

  final List<String> _tribunais = ['TJSP', 'TRF-2', 'TRF-3'];

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

  final List<String> _fases = [
    'Fase Postulatória',
    'Fase Instrutória',
    'Fase Decisória',
    'Fase Recursal',
    'Fase Executiva',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _initFCMToken();
  }

  Future<void> _initFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('Token FCM obtido: $fcmToken');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      setState(() {
        fcmToken = newToken;
      });
      print('Token FCM atualizado: $newToken');
    });
  }

  InputDecoration meuInputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 12.0,
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
      // Converte a data do campo para DateTime
      DateTime dataConvertida = DateFormat('dd/MM/yyyy').parse(dataCtrl.text);

      // Monta o objeto partes (lista de mapas)
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
        'numero_vara': numeroVaraCtrl.text,
        'vara': _selectedVara,
        'tribunal': _selectedTribunal,
        'juizado': _selectedJuizado,
        'andamento': _selectedAndamento,
        'fase_processual': _selectedFase,
        'assunto': assuntoCtrl.text,
        'historico': historicoCtrl.text,
        'partes': partes,
        'status': 'ativo',
        'usuarioId': FirebaseAuth.instance.currentUser!.uid,
        'token': fcmToken,
        'notificado': false,
      };

      // Salva no Firestore
      await FirebaseFirestore.instance.collection('processos').add(dados);

      // Feedback para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processo salvo com sucesso!')),
      );

      // Limpa os campos do formulário
      _limparCampos();
    } catch (e) {
      print('Erro ao salvar processo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar processo: $e')));
    }
  }

  void _limparCampos() {
    numeroCtrl.clear();
    dataCtrl.clear();
    valorCtrl.clear();
    numeroVaraCtrl.clear();
    andamentoCtrl.clear();
    faseCtrl.clear();
    assuntoCtrl.clear();
    historicoCtrl.clear();
    nomeParteCtrl.clear();
    cpfCnpjCtrl.clear();
    enderecoCtrl.clear();
    advogadoCtrl.clear();
    oabCtrl.clear();

    setState(() {
      _selectedVara = null;
      _selectedTribunal = null;
      _selectedJuizado = null;
      _selectedAndamento = null;
      _selectedFase = null;
      _currentStep = 0;
    });
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return GestureDetector(
      onTap:
          () => _showDropdownModal(
            context,
            label,
            options,
            selectedValue,
            onChanged,
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xffE0D3CA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE0D3CA), width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue ?? label,
                style: TextStyle(
                  color:
                      selectedValue != null
                          ? Colors.black87
                          : const Color.fromARGB(255, 132, 114, 102),
                  fontSize: 16,
                  fontWeight:
                      selectedValue != null
                          ? FontWeight.normal
                          : FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color.fromARGB(255, 132, 114, 102),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdownModal(
    BuildContext context,
    String label,
    List<String> options,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header do modal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF490A1D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selecionar $label',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de opções
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == currentValue;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected
                                  ? const Color(0xFF490A1D)
                                  : Colors.black87,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF490A1D),
                                size: 20,
                              )
                              : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              // Espaço inferior para o safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        );
      },
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
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: numeroVaraCtrl,
                decoration: meuInputDecoration("Nº"),
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildDropdownField("Vara*", _selectedVara, _varas, (v) {
                setState(() => _selectedVara = v);
              }),
            ),
          ],
        ),
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
        _buildDropdownField("Fase Processual*", _selectedFase, _fases, (v) {
          setState(() => _selectedFase = v);
        }),
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

  Widget _buildFixedStepIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título do passo atual
          Text(
            _getStepTitle(_currentStep),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF490A1D),
            ),
          ),
          const SizedBox(height: 10),

          // Progress bar com círculos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              bool isActive = index == _currentStep;
              bool isCompleted = index < _currentStep;

              return Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive
                              ? const Color(0xFF490A1D)
                              : isCompleted
                              ? const Color.fromARGB(255, 143, 23, 59)
                              : const Color(0xffE0D3CA),
                      border: Border.all(
                        color:
                            isActive || isCompleted
                                ? const Color(0xFF490A1D)
                                : Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow:
                          isActive
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF490A1D,
                                  ).withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child:
                          isCompleted
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                              : Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color:
                                      isActive
                                          ? Colors.white
                                          : isCompleted
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  if (index != 2)
                    Container(
                      width: 40,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color:
                            index < _currentStep
                                ? const Color(0xFF490A1D)
                                : const Color(0xffE0D3CA),
                      ),
                    ),
                ],
              );
            }),
          ),

          // Progress percentage
          const SizedBox(height: 8),
          Text(
            "${(((_currentStep + 1) / 3) * 100).round()}% Concluído",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return "Dados do Processo";
      case 1:
        return "Dados das Partes";
      case 2:
        return "Revisão e Confirmação";
      default:
        return "Cadastro de Processo";
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFormStep1();
      case 1:
        return _buildFormStep2();
      default:
        return Column(
          children: [
            const Icon(
              Icons.assignment_turned_in,
              size: 80,
              color: Color(0xFF490A1D),
            ),
            const SizedBox(height: 20),
            const Text(
              "Resumo Final do Processo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF490A1D),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffE0D3CA).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF490A1D).withOpacity(0.2),
                ),
              ),
              child: const Text(
                "Revise as informações inseridas e clique em 'Salvar' para finalizar o cadastro do processo.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cadastro de Processo"),
        centerTitle: true,
        backgroundColor: const Color(0xFF490A1D),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress bar fixa no topo
          _buildFixedStepIndicator(),

          // Conteúdo do formulário
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [_buildCurrentStep(), const SizedBox(height: 30)],
              ),
            ),
          ),

          // Botões fixos na parte inferior
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 55),
                        elevation: 4,
                        shadowColor: const Color.fromARGB(255, 64, 27, 39),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF490A1D),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text(
                        "Voltar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF490A1D),
                        ),
                      ),
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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 55),
                      elevation: 4,
                      shadowColor: const Color.fromARGB(255, 64, 27, 39),
                      backgroundColor: const Color(0xFF490A1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? "Salvar" : "Próximo passo",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
