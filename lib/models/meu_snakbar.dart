import 'package:flutter/material.dart';

void mostrarSnackBar({
  required BuildContext context,
  required String texto,
  Color backgroundColor = Colors.red, // padrão vermelho (caso de erro)
}) {
  final snackBar = SnackBar(
    content: Text(
      texto,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
