import 'package:flutter/material.dart';

void mostrarSnackBar({
  required BuildContext context,
  required String texto,
  Color? backgroundColor,
  SnackBarType type = SnackBarType.error,
}) {
  // Define cor e ícone baseado no tipo, se backgroundColor não for fornecida
  final Color corFundo;
  final IconData icone;
  
  if (backgroundColor != null) {
    corFundo = backgroundColor;
    // Define ícone baseado na cor para manter compatibilidade
    if (backgroundColor == Colors.green) {
      icone = Icons.check_circle;
    } else if (backgroundColor == Colors.red) {
      icone = Icons.error;
    } else if (backgroundColor == const Color(0xFF490A1D)) {
      icone = Icons.info;
    } else {
      icone = Icons.notifications;
    }
  } else {
    // Usa o tipo para definir cor e ícone
    switch (type) {
      case SnackBarType.success:
        corFundo = Colors.green;
        icone = Icons.check_circle;
        break;
      case SnackBarType.error:
        corFundo = Colors.red;
        icone = Icons.error;
        break;
      case SnackBarType.warning:
        corFundo = Colors.orange;
        icone = Icons.warning;
        break;
      case SnackBarType.info:
        corFundo = const Color(0xFF490A1D);
        icone = Icons.info;
        break;
    }
  }

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation(1),
            curve: Curves.easeOutBack,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícone contextual
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Texto
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Botão fechar
                GestureDetector(
                  onTap: () {
                    if (overlayEntry.mounted) {
                      overlayEntry.remove();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
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
    ),
  );

  overlay.insert(overlayEntry);

  // Remove automaticamente após 5 segundos com animação
  Future.delayed(const Duration(seconds: 5), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// Enum para tipos de notificação
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// Versão alternativa usando apenas SnackBar com posição customizada
void mostrarSnackBarTopo({
  required BuildContext context,
  required String texto,
  Color backgroundColor = Colors.red,
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          backgroundColor == Colors.green
              ? Icons.check_circle
              : backgroundColor == Colors.red
                  ? Icons.error
                  : Icons.info,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.only(
      bottom: MediaQuery.of(context).size.height - 150,
      left: 16,
      right: 16,
    ),
    dismissDirection: DismissDirection.up,
    elevation: 8,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}