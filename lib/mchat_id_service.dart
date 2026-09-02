import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MchatIdService {
  static const String ownerMchatId = '11111111';

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ===============================================================
  // VALIDATE MCHAT ID
  // ===============================================================

  static bool isValidMchatId(String id) {
    if (id.length != 8) {
      return false;
    }

    if (id == ownerMchatId) {
      return false;
    }

    return RegExp(r'^[0-9]{8}$').hasMatch(id);
  }

  // ===============================================================
  // ENSURE USER HAS MCHAT ID
  // ===============================================================

  static Future<String> ensureMchatId({
    required User user,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    final userRef =
        _db.collection('users').doc(user.uid);

    final userSnapshot =
        await userRef.get();

    final data =
        userSnapshot.data() ??
            <String, dynamic>{};

    // -------------------------------------------------------------
    // OWNER
    // -------------------------------------------------------------

    final bool isOwner =
        data['isOwner'] == true ||
        data['role']
                ?.toString()
                .toLowerCase() ==
            'owner';

    if (isOwner) {
      await _saveMchatIndex(
        mchatId: ownerMchatId,
        uid: user.uid,
        name: name.isNotEmpty
            ? name
            : 'Mchat Owner',
        email: email,
        photoUrl: photoUrl,
        isOwner: true,
      );

      await userRef.set(
        {
          'uid': user.uid,
          'name': name.isNotEmpty
              ? name
              : 'Mchat Owner',
          'email': email,
          'mchatId': ownerMchatId,
          'isOwner': true,
          'isOnline': true,
        },
        SetOptions(merge: true),
      );

      return ownerMchatId;
    }

    // -------------------------------------------------------------
    // CHECK EXISTING ID
    // -------------------------------------------------------------

    final existingValue =
        data['mchatId'];

    final existingId =
        existingValue
                ?.toString()
                .trim() ??
            '';

    if (isValidMchatId(existingId)) {
      final indexRef =
          _db
              .collection('mchatIds')
              .doc(existingId);

      final indexSnapshot =
          await indexRef.get();

      // Existing index belongs to this user.
      if (indexSnapshot.exists) {
        final indexData =
            indexSnapshot.data() ??
                <String, dynamic>{};

        final indexUid =
            indexData['uid']
                    ?.toString() ??
                '';

        if (indexUid == user.uid) {
          await _saveMchatIndex(
            mchatId: existingId,
            uid: user.uid,
            name: name,
            email: email,
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

      // If the ID is missing from index,
      // create the index for this user.
      if (!indexSnapshot.exists) {
        await _saveMchatIndex(
          mchatId: existingId,
          uid: user.uid,
          name: name,
          email: email,
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

      // If another user owns this ID,
      // generate a fresh ID.
    }

    // -------------------------------------------------------------
    // GENERATE NEW ID
    // -------------------------------------------------------------

    final String newMchatId =
        await _reserveNewMchatId(
      uid: user.uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );

    // -------------------------------------------------------------
    // SAVE USER PROFILE
    // -------------------------------------------------------------

    await userRef.set(
      {
        'uid': user.uid,
        'name': name.isNotEmpty
            ? name
            : 'Mchat User',
        'email': email,
        'mchatId': newMchatId,
        'coins': data['coins'] ?? 0,
        'vipLevel': data['vipLevel'] ?? 0,
        'isOwner': false,
        'isVolunteer':
            data['isVolunteer'] ?? false,
        'isOnline': true,
        'createdAt':
            data['createdAt'] ??
                FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return newMchatId;
  }

  // ===============================================================
  // RESERVE NEW UNIQUE ID
  // ===============================================================

  static Future<String> _reserveNewMchatId({
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    final random = Random.secure();

    while (true) {
      final int number =
          10000000 +
              random.nextInt(90000000);

      final String id =
          number.toString();

      // Never assign owner ID.
      if (id == ownerMchatId) {
        continue;
      }

      final DocumentReference<Map<String, dynamic>>
          indexRef =
          _db
              .collection('mchatIds')
              .doc(id);

      try {
        await _db.runTransaction(
          (transaction) async {
            final snapshot =
                await transaction.get(
              indexRef,
            );

            if (snapshot.exists) {
              throw const _MchatIdTaken();
            }

            transaction.set(
              indexRef,
              {
                'uid': uid,
                'mchatId': id,
                'name': name.isNotEmpty
                    ? name
                    : 'Mchat User',
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

  // ===============================================================
  // SAVE / UPDATE MCHAT INDEX
  // ===============================================================

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
        'name': name.isNotEmpty
            ? name
            : 'Mchat User',
        'email': email,
        'photoUrl': photoUrl,
        'isOwner': isOwner,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class _MchatIdTaken implements Exception {
  const _MchatIdTaken();
}
