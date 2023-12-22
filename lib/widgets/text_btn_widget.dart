import 'package:flutter/material.dart';

class TextBtnWidget extends StatelessWidget {
  final String? text1;
  final String? text2;
  const TextBtnWidget({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: text2,
              style: const TextStyle(
                color: Color.fromARGB(255, 52, 199, 59),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
