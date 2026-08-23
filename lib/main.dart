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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E35FF)),
        useMaterial3: true,
      ),
      home: const ProductionStatusPage(),
    );
  }
}

class ProductionStatusPage extends StatelessWidget {
  const ProductionStatusPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mchat')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Icon(Icons.verified_user, size: 70, color: Colors.deepPurple),
        SizedBox(height: 16),
        Text('Production Foundation', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(
          'Mchat is configured to use real backend data only. '
          'No demo balance, fake transactions, or fake withdrawal success is generated.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28),
        _Status('Authentication', 'Firebase configuration required'),
        _Status('Database', 'Firestore configuration required'),
        _Status('Payments', 'Merchant gateway credentials required'),
        _Status('Withdrawals', 'Verified payout/bank integration required'),
        _Status('Live / Voice', 'Live SDK credentials required'),
        _Status('Owner account', 'klofmanju221@gmail.com'),
        SizedBox(height: 24),
        Text(
          'Before production release, configure the services above and complete '
          'KYC, tax, privacy, terms, refund and app-store requirements.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _Status extends StatelessWidget {
  final String title;
  final String value;
  const _Status(this.title, this.value);

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.lock_outline),
      title: Text(title),
      subtitle: Text(value),
    ),
  );
}
