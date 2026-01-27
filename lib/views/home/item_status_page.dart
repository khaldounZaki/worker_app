import 'package:flutter/material.dart';

class ItemStatusPage extends StatelessWidget {
  const ItemStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // optional: implement a page that shows for a given item which roles have scanned it
    return Scaffold(
      appBar: AppBar(title: const Text('Item Status (Optional)')),
      body: const Center(child: Text('Not implemented yet')),
    );
  }
}
