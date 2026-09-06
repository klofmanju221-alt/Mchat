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
    final String value = id.trim();

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
  //
  // Referral information can be supplied during first creation.
  // No coins are added here.
  // ============================================================

  static Future<String> ensureMchatId({
    required User user,
    required String name,
    required String email,
    String photoUrl = '',
    String? referredByUid,
    String? referredByCode,
  }) async {
    final DocumentReference<Map<String, dynamic>> userRef =
        _db.collection('users').doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await userRef.get();

    final Map<String, dynamic> data =
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
          'name': cleanName.isEmpty
              ? 'Mchat Owner'
              : cleanName,
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
      final DocumentReference<Map<String, dynamic>> indexRef =
          _db.collection('mchatIds').doc(existingId);

      final DocumentSnapshot<Map<String, dynamic>> indexSnapshot =
          await indexRef.get();

      if (indexSnapshot.exists) {
        final Map<String, dynamic> indexData =
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

          await _saveExistingUserUpdates(
            userRef: userRef,
            data: data,
            name: cleanName,
            email: cleanEmail,
          );

          return existingId;
        }
      }

      // ID exists in user profile but index is missing.
      if (!indexSnapshot.exists) {
        await _saveMchatIndex(
          mchatId: existingId,
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          photoUrl: photoUrl,
          isOwner: false,
        );

        await _saveExistingUserUpdates(
          userRef: userRef,
          data: data,
          name: cleanName,
          email: cleanEmail,
        );

        return existingId;
      }

      // Another user owns this ID.
      // Generate a new ID below.
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
    // CREATE / SAVE USER PROFILE
    //
    // IMPORTANT:
    // Referral fields are included during creation.
    // This works with secure Firestore rules because the
    // initial user document is being created by that user.
    // ==========================================================

    final Map<String, dynamic> userData =
        <String, dynamic>{
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

      // Referral code belongs permanently to this user.
      'referralCode': 'MCHAT-$newMchatId',

      'successfulReferrals':
          data['successfulReferrals'] ?? 0,

      'referralCoins':
          data['referralCoins'] ?? 0,

      'referralUpdatedAt':
          FieldValue.serverTimestamp(),
    };

    // ==========================================================
    // INITIAL REFERRAL INFORMATION
    // ==========================================================

    final String cleanReferredByUid =
        referredByUid?.trim() ?? '';

    final String cleanReferredByCode =
        referredByCode?.trim().toUpperCase() ?? '';

    if (cleanReferredByUid.isNotEmpty &&
        cleanReferredByCode.isNotEmpty) {
      userData['referredByUid'] =
          cleanReferredByUid;

      userData['referredByCode'] =
          cleanReferredByCode;

      userData['referralStatus'] =
          'pending';

      userData['referredAt'] =
          FieldValue.serverTimestamp();
    }

    await userRef.set(
      userData,
      SetOptions(merge: true),
    );

    return newMchatId;
  }

  // ============================================================
  // SAVE EXISTING USER UPDATES
  //
  // Only safe profile/status fields are updated here.
  // Protected referral fields are NOT changed.
  // ============================================================

  static Future<void> _saveExistingUserUpdates({
    required DocumentReference<Map<String, dynamic>> userRef,
    required Map<String, dynamic> data,
    required String name,
    required String email,
  }) async {
    await userRef.set(
      {
        'uid': userRef.id,
        'name': name,
        'email': email,
        'isOnline': true,
      },
      SetOptions(merge: true),
    );
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
    final Random random = Random.secure();

    while (true) {
      final int number =
          10000000 + random.nextInt(90000000);

      final String id = number.toString();

      // Never assign Owner ID.
      if (id == ownerMchatId) {
        continue;
      }

      final DocumentReference<Map<String, dynamic>> indexRef =
          _db.collection('mchatIds').doc(id);

      try {
        await _db.runTransaction(
          (transaction) async {
            final DocumentSnapshot<Map<String, dynamic>>
                snapshot =
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
        'name':
            name.isEmpty ? 'Mchat User' : name,
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
    final String id = mchatId.trim();

    if (!RegExp(r'^[0-9]{8}$').hasMatch(id)) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db
            .collection('mchatIds')
            .doc(id)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }
}

// ============================================================
// INTERNAL MCHAT ID COLLISION EXCEPTION
// ============================================================

class _MchatIdTaken implements Exception {
  const _MchatIdTaken();
}
