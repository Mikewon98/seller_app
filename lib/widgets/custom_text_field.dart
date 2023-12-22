import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final bool? isObscure;
  final bool? enabled;
  final bool? enableSuggestion;
  final bool? autoCorrect;

  const CustomTextField({
    super.key,
    required this.controller,
    this.data,
    this.hintText,
    this.enabled = true,
    this.isObscure = false,
    this.enableSuggestion = true,
    this.autoCorrect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10.0),
      child: TextFormField(
        enableSuggestions: enableSuggestion!,
        autocorrect: autoCorrect!,
        controller: controller,
        obscureText: isObscure!,
        enabled: enabled,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(data, color: const Color(0xff5ac18e)),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black38,
          ),
        ),
      ),
    );
  }
}
