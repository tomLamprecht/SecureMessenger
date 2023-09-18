import 'package:flutter/material.dart';

typedef ValidationFunction = String? Function(String?);

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValidationFunction validationFunction;
  final String labelText;
  final bool isPassword;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.validationFunction,
    required this.labelText,
    required this.isPassword,
  });

  @override
  _ValidatedTextFieldState createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorMessage;

  @override
  void initState() {
    _errorMessage = widget.validationFunction('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorText: _errorMessage,
      ),
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : TextInputType.name,
      onChanged: (text) {
        setState(() {
          _errorMessage = widget.validationFunction(text);
        });
      },
    );
  }
}
