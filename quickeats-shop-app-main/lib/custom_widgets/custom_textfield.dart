import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final List<TextInputFormatter>? filteringTextInputFormatter;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.filteringTextInputFormatter,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(3, 3),
            blurRadius: 6,
            color: Colors.grey.shade400,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: filteringTextInputFormatter,
        validator: (value) => value == null || value.trim().isEmpty
            ? 'This field cannot be empty'
            : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 14),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
