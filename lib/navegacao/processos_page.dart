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
        ],
      ),
    );
  }
}
