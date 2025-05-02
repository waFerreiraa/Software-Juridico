import 'package:flutter/material.dart';
import 'package:jurisolutions/navegacao/cad_processo.dart';
import 'package:flutter/services.dart';

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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Processos e Casos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, size: 35),
            tooltip: 'Adicionar Processo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadPro()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/Advogado_.png',
                width: screenWidth * 0.6,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(18.0),
              child: Column(
                children: const [
                  Text(
                    "Gerencie e organize seus projetos com facilidade.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Tenha todos os casos do seu escritório em um só lugar!",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Você pode adicionar nas duas formas abaixo.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              height: 115,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xffE0D3CA),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Com o número do CNJ",
                    style: TextStyle(
                      color: Color(0xff5E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Realize a busca individual de processos de primeira instância pelo número CNJ. Ideal para cadastrar um único processo.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              height: 115,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xffE0D3CA),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Cadastro em lote com número OAB",
                    style: TextStyle(
                      color: Color(0xff5E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Registre facilmente seus processos ativos vinculados ao OAB do advogado. A forma mais prática de gerenciar seus casos!",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
