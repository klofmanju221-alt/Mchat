import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MchatIdService {
  MchatIdService._();

  static const String ownerMchatId = '11111111';

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ============================================================
  // VALIDATE MCHAT ID
  // ============================================================

  static bool isValidMchatId(String id) {
    final value = id.trim();

    if (value.length != 8) {
      return false;
    }

    if (value == ownerMchatId) {
      return false;
    }

    return RegExp(r'^[0-9]{8}$').hasMatch(value);
  }

  // ============================================================
  // ENSURE USER HAS MCHAT ID
  // ============================================================

  static Future<String> ensureMchatId({
    required User user,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    final userRef = _db.collection('users').doc(user.uid);

    final userSnapshot = await userRef.get();

    final data =
        userSnapshot.data() ?? <String, dynamic>{};

    final String cleanName =
        name.trim().isEmpty ? 'Mchat User' : name.trim();

    final String cleanEmail = email.trim();

    // ==========================================================
    // OWNER
    // ==========================================================

    final bool isOwner =
        data['isOwner'] == true ||
        data['role']?.toString().toLowerCase() == 'owner';

    if (isOwner) {
      await _saveMchatIndex(
        mchatId: ownerMchatId,
        uid: user.uid,
        name: cleanName.isEmpty ? 'Mchat Owner' : cleanName,
        email: cleanEmail,
        photoUrl: photoUrl,
        isOwner: true,
      );

      await userRef.set(
        {
          'uid': user.uid,
          'name': cleanName.isEmpty ? 'Mchat Owner' : cleanName,
          'email': cleanEmail,
          'mchatId': ownerMchatId,
          'isOwner': true,
          'isOnline': true,
        },
        SetOptions(merge: true),
      );

      return ownerMchatId;
    }

    // ==========================================================
    // CHECK EXISTING USER ID
    // ==========================================================

    final String existingId =
        data['mchatId']?.toString().trim() ?? '';

    if (isValidMchatId(existingId)) {
      final indexRef =
          _db.collection('mchatIds').doc(existingId);

      final indexSnapshot = await indexRef.get();

      if (indexSnapshot.exists) {
        final indexData =
            indexSnapshot.data() ?? <String, dynamic>{};

        final String indexUid =
            indexData['uid']?.toString() ?? '';

        // Existing ID belongs to this user.
        if (indexUid == user.uid) {
          await _saveMchatIndex(
            mchatId: existingId,
            uid: user.uid,
            name: cleanName,
            email: cleanEmail,
            photoUrl: photoUrl,
            isOwner: false,
          );

          await userRef.set(
            {
              'isOnline': true,
            },
            SetOptions(merge: true),
          );

          return existingId;
        }
      }

      // ID is not indexed yet.
      if (!indexSnapshot.exists) {
        await _saveMchatIndex(
          mchatId: existingId,
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          photoUrl: photoUrl,
          isOwner: false,
        );

        await userRef.set(
          {
            'isOnline': true,
          },
          SetOptions(merge: true),
        );

        return existingId;
      }

      // Another user owns this ID.
      // A new ID will be generated below.
    }

    // ==========================================================
    // GENERATE NEW UNIQUE ID
    // ==========================================================

    final String newMchatId =
        await _reserveNewMchatId(
      uid: user.uid,
      name: cleanName,
      email: cleanEmail,
      photoUrl: photoUrl,
    );

    // ==========================================================
    // SAVE USER PROFILE
    // ==========================================================

    await userRef.set(
      {
        'uid': user.uid,
        'name': cleanName,
        'email': cleanEmail,
        'mchatId': newMchatId,
        'coins': data['coins'] ?? 0,
        'vipLevel': data['vipLevel'] ?? 0,
        'isOwner': false,
        'isVolunteer': data['isVolunteer'] ?? false,
        'isOnline': true,
        'createdAt':
            data['createdAt'] ??
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return newMchatId;
  }

  // ============================================================
  // RESERVE UNIQUE 8-DIGIT ID
  // ============================================================

  static Future<String> _reserveNewMchatId({
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    final random = Random.secure();

    while (true) {
      final int number =
          10000000 + random.nextInt(90000000);

      final String id = number.toString();

      // Never assign Owner ID.
      if (id == ownerMchatId) {
        continue;
      }

      final indexRef =
          _db.collection('mchatIds').doc(id);

      try {
        await _db.runTransaction(
          (transaction) async {
            final snapshot =
                await transaction.get(indexRef);

            // Someone already has this ID.
            if (snapshot.exists) {
              throw const _MchatIdTaken();
            }

            transaction.set(
              indexRef,
              {
                'uid': uid,
                'mchatId': id,
                'name': name,
                'email': email,
                'photoUrl': photoUrl,
                'isOwner': false,
                'createdAt':
                    FieldValue.serverTimestamp(),
              },
            );
          },
        );

        return id;
      } on _MchatIdTaken {
        // Try another random ID.
        continue;
      }
    }
  }

  // ============================================================
  // SAVE / UPDATE MCHAT INDEX
  // ============================================================

  static Future<void> _saveMchatIndex({
    required String mchatId,
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
    required bool isOwner,
  }) async {
    await _db
        .collection('mchatIds')
        .doc(mchatId)
        .set(
      {
        'uid': uid,
        'mchatId': mchatId,
        'name': name.isEmpty ? 'Mchat User' : name,
        'email': email,
        'photoUrl': photoUrl,
        'isOwner': isOwner,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // FIND USER BY MCHAT ID
  // ============================================================

  static Future<Map<String, dynamic>?> findByMchatId(
    String mchatId,
  ) async {
    final id = mchatId.trim();

    if (!RegExp(r'^[0-9]{8}$').hasMatch(id)) {
      return null;
    }

    final snapshot =
        await _db.collection('mchatIds').doc(id).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }
}

class _MchatIdTaken implements Exception {
  const _MchatIdTaken();
}
