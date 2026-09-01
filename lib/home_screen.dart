import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mchat'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Mchat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connect • Chat • Share • Enjoy',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
