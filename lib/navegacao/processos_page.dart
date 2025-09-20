import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jurisolutions/navegacao/cad_processo.dart';
import 'package:jurisolutions/navegacao/casosAtivos.dart';

class ProcessosPage extends StatefulWidget {
  const ProcessosPage({super.key});

  @override
  State<ProcessosPage> createState() => _ProcessosPageState();
}

class _ProcessosPageState extends State<ProcessosPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Processos e Casos",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Removidos os IconButton
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          final double maxContentWidth =
              isDesktop ? 700 : constraints.maxWidth * 0.9;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Advogado_.png',
                      width: isDesktop ? 400 : constraints.maxWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "Gerencie e organize seus projetos com facilidade.",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tenha todos os casos do seu escritório em um só lugar!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),

                    const SizedBox(height: 50),
                    isDesktop
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _infoCard(
                                context: context,
                                title: "Com o número do CNJ",
                                description:
                                    "Realize a busca individual de processos de primeira instância pelo número CNJ. Ideal para cadastrar um único processo.",
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _infoCard(
                                context: context,
                                title: "Cadastro em lote com número OAB",
                                description:
                                    "Registre facilmente seus processos ativos vinculados ao OAB do advogado. A forma mais prática de gerenciar seus casos!",
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CadPro(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(320, 48),
                                elevation: 4,
                                shadowColor: const Color.fromARGB(
                                  255,
                                  74,
                                  43,
                                  53,
                                ),
                                backgroundColor: const Color(0xFF490A1D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: Text(
                                "Adicionar Processo",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CasosAtivos(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(320, 48),
                                elevation: 4,
                                shadowColor: const Color.fromARGB(
                                  255,
                                  74,
                                  43,
                                  53,
                                ),
                                backgroundColor: const Color(0xFF490A1D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: Text(
                                "Casos Ativos",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final cardColor = const Color(0xffE0D3CA);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 8),
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
