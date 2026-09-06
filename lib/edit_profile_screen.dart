import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'premium_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String _email = '';
  String _mchatId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data =
          snapshot.data() ?? <String, dynamic>{};

      final String name =
          (data['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString();

      final String email =
          (data['email'] ??
                  user.email ??
                  'No email')
              .toString();

      final String mchatId =
          (data['mchatId'] ?? 'Not assigned')
              .toString();

      if (!mounted) return;

      setState(() {
        _nameController.text = name;
        _email = email;
        _mchatId = mchatId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        'Unable to load profile.',
        isError: true,
      );
    }
  }

  Future<void> _saveProfile() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login again.',
        isError: true,
      );
      return;
    }

    final String name =
        _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
        isError: true,
      );
      return;
    }

    if (name.length < 2) {
      _showMessage(
        'Name must contain at least 2 characters.',
        isError: true,
      );
      return;
    }

    if (name.length > 50) {
      _showMessage(
        'Name cannot exceed 50 characters.',
        isError: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final DocumentReference<Map<String, dynamic>>
          userRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);

      // ----------------------------------------------------------
      // REAL FIRESTORE UPDATE
      // ----------------------------------------------------------

      await userRef.set(
        {
          'uid': user.uid,
          'name': name,
          'email': _email,
          'mchatId': _mchatId,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ----------------------------------------------------------
      // UPDATE FIREBASE AUTH DISPLAY NAME
      // ----------------------------------------------------------

      await user.updateDisplayName(name);

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Profile updated successfully.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Unable to save profile. Please try again.',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError
                  ? Colors.red.shade800
                  : PremiumTheme.surface2,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: PremiumTheme.background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: Text(
            'Please login again.',
            style: PremiumTheme.bodyText,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: PremiumTheme.gold,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient:
                        PremiumTheme.purpleGradient,
                    borderRadius:
                        BorderRadius.circular(24),
                    border: Border.all(
                      color: PremiumTheme.gold
                          .withValues(alpha: 0.55),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: PremiumTheme.gold,
                        size: 46,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Edit Your Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Keep your Mchat profile updated',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // NAME
                // ==================================================

                const Text(
                  'Name',
                  style: TextStyle(
                    color: PremiumTheme.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _nameController,
                  textCapitalization:
                      TextCapitalization.words,
                  maxLength: 50,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration:
                      const InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_rounded,
                    ),
                    hintText: 'Enter your name',
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // EMAIL - READ ONLY
                // ==================================================

                const Text(
                  'Email',
                  style: TextStyle(
                    color: PremiumTheme.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      TextEditingController(
                    text: _email,
                  ),
                  readOnly: true,
                  enabled: false,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  decoration:
                      const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_rounded,
                    ),
                    suffixIcon: Icon(
                      Icons.lock_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // MCHAT ID - LOCKED
                // ==================================================

                const Text(
                  'Mchat ID',
                  style: TextStyle(
                    color: PremiumTheme.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration:
                      PremiumTheme.premiumCard(
                    radius: 16,
                  ),
                  child: Row(
                    children: [
                      PremiumTheme.iconBox(
                        Icons.badge_rounded,
                        size: 46,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Mchat ID',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _mchatId,
                              style: const TextStyle(
                                color:
                                    PremiumTheme.gold,
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Mchat ID cannot be changed.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style:
                        PremiumTheme.premiumButton(),
                    icon: Icon(
                      _saving
                          ? Icons.hourglass_top_rounded
                          : Icons.save_rounded,
                    ),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : 'SAVE PROFILE',
                    ),
                    onPressed:
                        _saving
                            ? null
                            : _saveProfile,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // CANCEL
                // ==================================================

                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    style:
                        PremiumTheme.outlinedButton(),
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    label: const Text(
                      'CANCEL',
                    ),
                    onPressed:
                        _saving
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                );
                              },
                  ),
                ),
              ],
            ),
    );
  }
}
