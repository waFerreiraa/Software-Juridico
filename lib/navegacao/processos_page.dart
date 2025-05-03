import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jurisolutions/navegacao/cad_processo.dart';

class ProcessosPage extends StatefulWidget {
  const ProcessosPage({super.key});

  @override
  State<ProcessosPage> createState() => _ProcessosPageState();
}

class _ProcessosPageState extends State<ProcessosPage> {
  @override
  void initState() {
    super.initState();
    // Ajusta a cor da barra de status conforme o modo do sistema
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Processos e Casos",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'Adicionar Processo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadPro()),
              );
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: theme.iconTheme.color,
        ),
        flexibleSpace: Container(
          color: theme.scaffoldBackgroundColor,
        ),
      ),
      body: Builder(
        builder: (context) {
          // Verifica se o conteúdo ultrapassa a altura da tela
          bool isScrollable = screenHeight * 0.8 < screenHeight;
          
          // Se o conteúdo for maior que a tela, usa o SingleChildScrollView
          if (isScrollable) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _buildContent(context, screenWidth, theme, screenHeight),
            );
          } else {
            return _buildContent(context, screenWidth, theme, screenHeight);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth, ThemeData theme, double screenHeight) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/Advogado_.png',
            width: screenWidth * 0.6,
            fit: BoxFit.contain,
          ),
        ),
        Container(
          margin: EdgeInsets.all(screenWidth * 0.04),  // Diminui o espaço entre o texto e as bordas
          child: Column(
            children: [
              Text(
                "Gerencie e organize seus projetos com facilidade.",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.015), // Menor espaçamento entre os widgets
              Text(
                "Tenha todos os casos do seu escritório em um só lugar!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                "Você pode adicionar nas duas formas abaixo.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _infoCard(
          context: context,
          title: "Com o número do CNJ",
          description:
              "Realize a busca individual de processos de primeira instância pelo número CNJ. Ideal para cadastrar um único processo.",
        ),
        _infoCard(
          context: context,
          title: "Cadastro em lote com número OAB",
          description:
              "Registre facilmente seus processos ativos vinculados ao OAB do advogado. A forma mais prática de gerenciar seus casos!",
        ),
      ],
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]
        : const Color(0xffE0D3CA);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.03), // Menor espaçamento
      padding: const EdgeInsets.all(10), // Menor padding dentro do card
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xff5E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.008),  // Menor espaçamento
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
