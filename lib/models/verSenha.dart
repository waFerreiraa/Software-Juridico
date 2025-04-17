import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;

  const CampoSenha({
    super.key,
    required this.controller,
    this.hintText = "Senha",
    this.validator,
    this.decoration,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CampoSenhaState createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _obscureText = true;

  void _alternarVisibilidade() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: widget.decoration?.copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _alternarVisibilidade,
        ),
      ),
    );
  }
}
