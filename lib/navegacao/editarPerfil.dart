import 'package:flutter/material.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final TextEditingController nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            Text(
              "Nome",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // CAMPO DE TEXTO
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 97, 97, 97) // CINZA NO MODO ESCURO
              : const Color(0xFFE0D3CA), // COR NO MODO CLARO
                hintText: "Digite seu nome",
                hintStyle: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? const Color.fromARGB(242, 255, 255, 255)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica de salvar entra aqui
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF490A1D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Salvar",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
