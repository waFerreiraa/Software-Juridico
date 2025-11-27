import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class EditarProcessoScreen extends StatefulWidget {
  final String processoId;

  const EditarProcessoScreen({super.key, required this.processoId});

  @override
  State<EditarProcessoScreen> createState() => _EditarProcessoScreenState();
}

class _EditarProcessoScreenState extends State<EditarProcessoScreen> {
  int _currentStep = 0;
  bool _isLoading = true;

  final numeroCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final numeroVaraCtrl = TextEditingController();
  final assuntoCtrl = TextEditingController();
  final historicoCtrl = TextEditingController();

  final nomeParteCtrl = TextEditingController();
  final cpfCnpjCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final advogadoCtrl = TextEditingController();
  final oabCtrl = TextEditingController();

  String? _selectedVara;
  String? _selectedTribunal;
  String? _selectedJuizado;
  String? _selectedAndamento;
  String? _selectedFase;

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
  final valorFormatter = MoneyInputFormatter(
    leadingSymbol: 'R\$',
    useSymbolPadding: true,
    thousandSeparator: ThousandSeparator.Period, // separador de milhar
    mantissaLength: 2, // número de casas decimais
  );

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

  final String usuarioId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _carregarProcesso();
  }

  Future<void> _carregarProcesso() async {
    try {
      DocumentSnapshot processoDoc =
          await FirebaseFirestore.instance.collection('processos').doc(widget.processoId).get();

      if (!processoDoc.exists) {
        if (mounted) {
          mostrarSnackBar(
            context: context,
            texto: 'Processo não encontrado.',
            backgroundColor: Colors.red,
          );
          Navigator.pop(context);
        }
        return;
      }

      final processoData = processoDoc.data() as Map<String, dynamic>;

      if (processoData['usuarioId'] != usuarioId) {
        if (mounted) {
          mostrarSnackBar(
            context: context,
            texto: 'Você não tem permissão para editar este processo.',
            backgroundColor: Colors.red,
          );
          Navigator.pop(context);
        }
        return;
      }

      numeroCtrl.text = processoData['numero'] ?? '';
      dataCtrl.text = processoData['data'] ?? '';
      final valor = processoData['valor'] ?? 0.0;
      valorCtrl.text = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
      numeroVaraCtrl.text = processoData['numero_vara'] ?? '';
      assuntoCtrl.text = processoData['assunto'] ?? '';
      historicoCtrl.text = processoData['historico'] ?? '';

      _selectedVara = processoData['vara'];
      _selectedTribunal = processoData['tribunal'];
      _selectedJuizado = processoData['juizado'];
      _selectedAndamento = processoData['andamento'];
      _selectedFase = processoData['fase_processual'];

      if (processoData['partes'] != null && (processoData['partes'] as List).isNotEmpty) {
        final parte1 = processoData['partes'][0];
        nomeParteCtrl.text = parte1['nome'] ?? '';
        cpfCnpjCtrl.text = parte1['cpf_cnpj'] ?? '';
        enderecoCtrl.text = parte1['endereco'] ?? '';
        advogadoCtrl.text = parte1['advogado'] ?? '';
        oabCtrl.text = parte1['oab'] ?? '';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        mostrarSnackBar(
          context: context,
          texto: 'Erro ao carregar dados: $e',
          backgroundColor: Colors.red,
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _salvarProcesso() async {
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
        'valor': double.tryParse(valorCtrl.text.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.')) ?? 0.0,
        'numero_vara': numeroVaraCtrl.text,
        'vara': _selectedVara,
        'tribunal': _selectedTribunal,
        'juizado': _selectedJuizado,
        'andamento': _selectedAndamento,
        'fase_processual': _selectedFase,
        'assunto': assuntoCtrl.text,
        'historico': historicoCtrl.text,
        'partes': partes,
      };

      await FirebaseFirestore.instance.collection('processos').doc(widget.processoId).update(dados);

      if (mounted) {
        mostrarSnackBar(
          context: context,
          texto: 'Processo atualizado com sucesso!',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        mostrarSnackBar(
          context: context,
          texto: 'Erro ao salvar processo: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  InputDecoration meuInputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      filled: true,
      fillColor: isDark ? Colors.grey[850] : const Color(0xffE0D3CA),
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : const Color.fromARGB(255, 132, 114, 102),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.white54 : const Color.fromARGB(255, 181, 164, 150), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : const Color(0xffE0D3CA), width: 2),
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

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showDropdownModal(context, label, options, selectedValue, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : const Color(0xffE0D3CA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xffE0D3CA), width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue ?? label,
                style: TextStyle(
                  color: selectedValue != null ? (isDark ? Colors.white70 : Colors.black87) : (isDark ? Colors.white70 : const Color.fromARGB(255, 132, 114, 102)),
                  fontSize: 16,
                  fontWeight: selectedValue != null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white70 : const Color.fromARGB(255, 132, 114, 102),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF490A1D),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selecionar $label',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == currentValue;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        option,
                        style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF490A1D) : (isDark ? Colors.white70 : Colors.black87)),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF490A1D), size: 20) : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
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
        TextFormField(controller: numeroCtrl, inputFormatters: [numeroProcessoFormatter], keyboardType: TextInputType.number, decoration: meuInputDecoration("Número*")),
        const SizedBox(height: 16),
        TextFormField(controller: dataCtrl, decoration: meuInputDecoration("Data*"), readOnly: true, onTap: () => _selecionarData(context)),
        const SizedBox(height: 16),
        TextFormField(controller: valorCtrl, keyboardType: TextInputType.number, inputFormatters: [valorFormatter], decoration: meuInputDecoration("Valor*")),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 1, child: TextFormField(controller: numeroVaraCtrl, keyboardType: TextInputType.number, decoration: meuInputDecoration("Nº") )),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: _buildDropdownField("Vara*", _selectedVara, _varas, (v) => setState(() => _selectedVara = v))),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdownField("Tribunal*", _selectedTribunal, _tribunais, (v) => setState(() => _selectedTribunal = v)),
        const SizedBox(height: 16),
        _buildDropdownField("Juizado*", _selectedJuizado, _juizados, (v) => setState(() => _selectedJuizado = v)),
        const SizedBox(height: 16),
        _buildDropdownField("Andamento*", _selectedAndamento, _andamentos, (v) => setState(() => _selectedAndamento = v)),
        const SizedBox(height: 16),
        _buildDropdownField("Fase Processual*", _selectedFase, _fases, (v) => setState(() => _selectedFase = v)),
        const SizedBox(height: 16),
        TextFormField(controller: assuntoCtrl, decoration: meuInputDecoration("Assunto*")),
        const SizedBox(height: 16),
        TextFormField(controller: historicoCtrl, decoration: meuInputDecoration("Histórico*")),
      ],
    );
  }

  Widget _buildFormStep2() {
    return Column(
      children: [
        TextFormField(controller: nomeParteCtrl, decoration: meuInputDecoration("Nome*")),
        const SizedBox(height: 16),
        TextFormField(controller: cpfCnpjCtrl, keyboardType: TextInputType.number, inputFormatters: [cpfCnpjFormatter], decoration: meuInputDecoration("CPF/CNPJ*")),
        const SizedBox(height: 16),
        TextFormField(controller: enderecoCtrl, decoration: meuInputDecoration("Endereço*")),
        const SizedBox(height: 16),
        TextFormField(controller: advogadoCtrl, decoration: meuInputDecoration("Advogado*")),
        const SizedBox(height: 16),
        TextFormField(controller: oabCtrl, decoration: meuInputDecoration("OAB*")),
      ],
    );
  }

  Widget _buildFixedStepIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getStepTitle(_currentStep),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: (_currentStep == 0 || _currentStep == 1)
                  ? (isDark ? Colors.white : const Color(0xFF490A1D))
                  : const Color(0xFF490A1D),
            ),
          ),
          const SizedBox(height: 10),
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
                      color: isActive
                          ? const Color(0xFF490A1D) // Passo atual: sempre vinho
                          : isCompleted
                              ? const Color(0xFF8F173B) // Passos concluídos: vinho mais claro
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 68, 67, 67) // Passos futuros no dark: cinza
                                  : const Color(0xFFE0D3CA), // Passos futuros no light: creme/bege
                      border: Border.all(
                        color: isActive || isCompleted
                            ? const Color(0xFF490A1D)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive || isCompleted
                              ? const Color.fromARGB(255, 202, 193, 193) //cor do numero presente
                              : const Color.fromARGB(255, 255, 255, 255),// cor do numero que ainda vai
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (index < 2)
                    Container(
                      width: 40,
                      height: 2,
                      color: const Color(0xFF490A1D),
                    ),
                ],
              );




            }),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Informações do Processo';
      case 1:
        return 'Partes Envolvidas';
      case 2:
        return 'Finalizar';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Processo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF490A1D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFixedStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_currentStep == 0) _buildFormStep1(),
                        if (_currentStep == 1) _buildFormStep2(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _currentStep--),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.grey[700] : Colors.transparent, // fundo cinza no dark
                                    side: BorderSide(color: isDark ? const Color.fromARGB(255, 255, 255, 255)! : const Color(0xFF490A1D)), // borda cinza no dark
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    'Voltar',
                                    style: TextStyle(color: isDark ? const Color.fromARGB(255, 255, 255, 255) : const Color(0xFF490A1D)), // texto branco no dark
                                  ),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_currentStep == 1) {
                                    _salvarProcesso();
                                  } else {
                                    setState(() => _currentStep++);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF490A1D),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  _currentStep == 1 ? 'Salvar' : 'Próximo',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}