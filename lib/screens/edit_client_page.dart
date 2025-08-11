import 'package:flutter/material.dart';

class EditClientPage extends StatelessWidget {
  const EditClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
      ),
      body: const Center(
        child: Text('Client form goes here'),
      ),
    );
  }
}
