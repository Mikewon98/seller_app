import 'package:flutter/material.dart';
import 'package:seller_app/widgets/progress.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Progress(),
          const SizedBox(
            height: 10,
          ),
          Text("${message!} Please wait.."),
        ],
      ),
    );
  }
}
