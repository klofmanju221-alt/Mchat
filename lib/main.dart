import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseError;

  try {
    await Firebase.initializeApp();
  } catch (e) {
    firebaseError = e.toString();
  }

  runApp(MchatApp(firebaseError: firebaseError));
}

class MchatApp extends StatelessWidget {
  final String? firebaseError;

  const MchatApp({
    super.key,
    this.firebaseError,
  });

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
      home: firebaseError == null
          ? const ProductionStatusPage()
          : FirebaseErrorPage(error: firebaseError!),
    );
  }
}

class ProductionStatusPage extends StatelessWidget {
  const ProductionStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mchat'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Icon(
            Icons.verified_user,
            size: 70,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 16),
          Text(
            'Mchat Production Foundation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Firebase connected successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 28),
          _Status(
            'Authentication',
            'Firebase Authentication ready',
          ),
          _Status(
            'Database',
            'Cloud Firestore configured',
          ),
          _Status(
            'Payments',
            'Server verification required',
          ),
          _Status(
            'Withdrawals',
            'Verified payout integration required',
          ),
          _Status(
            'Live / Voice',
            'Live SDK credentials required',
          ),
        ],
      ),
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  final String error;

  const FirebaseErrorPage({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mchat - Firebase Error'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Firebase Initialization Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please send this error to the developer:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            SelectableText(
              error,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String title;
  final String value;

  const _Status(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
