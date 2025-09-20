import 'package:flutter/material.dart';

void mostrarSnackBar({
  required BuildContext context,
  required String texto,
  Color backgroundColor = Colors.red, // padrão vermelho (caso de erro)
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top:
              MediaQuery.of(context).padding.top +
              10, // Posição no topo + safe area
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      overlayEntry.remove();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  // Remove automaticamente após 3 segundos
  Future.delayed(const Duration(seconds: 7), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// Versão alternativa usando apenas SnackBar com posição customizada
void mostrarSnackBarTopo({
  required BuildContext context,
  required String texto,
  Color backgroundColor = Colors.red,
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
    margin: EdgeInsets.only(
      bottom:
          MediaQuery.of(context).size.height - 150, // Força aparecer no topo
      left: 16,
      right: 16,
    ),
    dismissDirection: DismissDirection.up, // Permite dismiss para cima
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
