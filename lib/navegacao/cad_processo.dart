import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CadProcesso { geral, partes }

class CadPro extends StatefulWidget {
  const CadPro({super.key});

  @override
  State<CadPro> createState() => _CadProState();
}

class _CadProState extends State<CadPro> {
  CadProcesso cadproView = CadProcesso.geral;

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
      contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
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

  Widget _buildForm(List<String> campos, double largura) {
    return Column(
      children: [
        for (var label in campos) ...[
          TextFormField(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: meuInputDecoration(label),
          ),
          const SizedBox(height: 30),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: SizedBox(
            width: largura,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
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
    return _buildForm([
      "Número*",
      "Data*",
      "Valor*",
      "Vara*",
      "Tribunal*",
      "Juizado*",
      "Andamento*",
      "Fase Processual*",
      "Assunto*"
    ], largura);
  }

  Widget _buildPartesEnvolvidas(double largura) {
    return _buildForm([
      "Nome*",
      "CPF/CNPJ*",
      "Endereço*",
      "Advogado*",
      "OAB*"
    ], largura);
  }

  @override
  Widget build(BuildContext context) {
    final double larguraTela = MediaQuery.of(context).size.width;
    final double larguraMax = larguraTela * 0.9 > 500 ? 500.0 : larguraTela * 0.9;

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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Center(
              child: IntrinsicWidth(
                child: SegmentedButton<CadProcesso>(
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    ButtonSegment<CadProcesso>(
                      value: CadProcesso.partes,
                      label: Text(
                        'Partes Envolvidas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: cadproView == CadProcesso.geral
                    ? _buildInformacoesGerais(larguraMax)
                    : _buildPartesEnvolvidas(larguraMax),
              ),
            );
          },
        ),
      ),
    );
  }
}
