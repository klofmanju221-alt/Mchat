import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MchatApp());
}

class MchatApp extends StatelessWidget {
  const MchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mchat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E35FF),
        ),
        useMaterial3: true,
      ),
      home: const MchatHomePage(),
    );
  }
}

class MchatHomePage extends StatelessWidget {
  const MchatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mchat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.chat,
              size: 80,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'Mchat',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'App launched successfully',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
