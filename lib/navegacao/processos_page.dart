import 'package:flutter/material.dart';

class ProcessosPage extends StatelessWidget {
  const ProcessosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Processos e casos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Center(
            child: Image.asset(
              'assets/Advogado_.png',
              width: 280,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: EdgeInsets.all(18.0),
            child: Column(
              children: [
                Text(
                  "Gerencie e organize seus projetos com facilidade.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(padding: const EdgeInsets.all(15.0)),
                Text("Tenha todos os casos do seu escritório em um só lugar!"),
                Text("Voçê pode adicionar nas duas formas abaixo."),
              ],
            ),
          ),
          Container(
            width: 400,
            height: 115,
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xffE0D3CA),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Com o número do CNJ",
                  style: TextStyle(
                    color: Color(0xff5E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Realize a busca individual de processos de primeira de instância pelo número CNJ.Ideal para para cadrastar um único processo",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}