import 'package:flutter/material.dart';

class MyEarningPage extends StatefulWidget {
  const MyEarningPage({super.key});

  @override
  State<MyEarningPage> createState() => _MyEarningPageState();
}

class _MyEarningPageState extends State<MyEarningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My earnings"),
      ),
    );
  }
}
