// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final RegExp validationRegEx;
  final obscureText;
  final void Function(String?) onSaved;
  CustomFormField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.validationRegEx,
    this.obscureText = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.1,
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 186, 183, 183)),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value != null && validationRegEx.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${labelText.toLowerCase()}";
        },
        onSaved: onSaved,
      ),
    );
  }
}
