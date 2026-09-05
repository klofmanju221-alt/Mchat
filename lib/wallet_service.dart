import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  WalletService._();

  static final WalletService instance =
      WalletService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Stream<int> coinBalanceStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream<int>.value(0);
    }

    return _firestore
        .collection('wallets')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return 0;
      }

      final balance = data['coinBalance'];

      if (balance is int) {
        return balance;
      }

      if (balance is num) {
        return balance.toInt();
      }

      return 0;
    });
  }

  Future<int> getCoinBalance() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 0;
    }

    final snapshot = await _firestore
        .collection('wallets')
        .doc(user.uid)
        .get();

    final data = snapshot.data();

    if (data == null) {
      return 0;
    }

    final balance = data['coinBalance'];

    if (balance is int) {
      return balance;
    }

    if (balance is num) {
      return balance.toInt();
    }

    return 0;
  }
}
