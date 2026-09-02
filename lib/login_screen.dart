import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // ===============================================================
  // OWNER MCHAT ID
  // ===============================================================

  static const String ownerMchatId = '11111111';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // GENERATE UNIQUE 8-DIGIT MCHAT ID
  // ===============================================================

  Future<String> _generateUniqueMchatId() async {
    final random = Random.secure();

    while (true) {
      final int number =
          10000000 + random.nextInt(90000000);

      final String id = number.toString();

      // -----------------------------------------------------------
      // Owner ID must never be assigned to normal users.
      // -----------------------------------------------------------

      if (id == ownerMchatId) {
        continue;
      }

      final result = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'mchatId',
            isEqualTo: id,
          )
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        return id;
      }
    }
  }

  // ===============================================================
  // CREATE / REPAIR USER PROFILE
  // ===============================================================

  Future<String> _ensureMchatId(User user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final snapshot = await userRef.get();

    final Map<String, dynamic> data =
        snapshot.data() ?? <String, dynamic>{};

    // -------------------------------------------------------------
    // OWNER ACCOUNT
    // -------------------------------------------------------------

    final bool isOwner =
        data['isOwner'] == true ||
        data['role']?.toString().toLowerCase() == 'owner';

    if (isOwner) {
      await userRef.set(
        {
          'uid': user.uid,
          'name': data['name'] ??
              user.displayName ??
              'Mchat Owner',
          'email': data['email'] ??
              user.email ??
              '',
          'mchatId': ownerMchatId,
          'isOwner': true,
          'isOnline': true,
        },
        SetOptions(merge: true),
      );

      return ownerMchatId;
    }

    // -------------------------------------------------------------
    // EXISTING USER ALREADY HAS MCHAT ID
    // -------------------------------------------------------------

    final dynamic existingValue =
        data['mchatId'];

    final String existingId =
        existingValue?.toString().trim() ?? '';

    if (_isValidMchatId(existingId)) {
      // Make sure online status is updated.
      await userRef.set(
        {
          'isOnline': true,
        },
        SetOptions(merge: true),
      );

      return existingId;
    }

    // -------------------------------------------------------------
    // OLD USER WITHOUT MCHAT ID
    // -------------------------------------------------------------

    final String newMchatId =
        await _generateUniqueMchatId();

    await userRef.set(
      {
        'uid': user.uid,
        'name': data['name'] ??
            user.displayName ??
            'Mchat User',
        'email': data['email'] ??
            user.email ??
            '',
        'mchatId': newMchatId,
        'coins': data['coins'] ?? 0,
        'vipLevel': data['vipLevel'] ?? 0,
        'isOwner': false,
        'isVolunteer': data['isVolunteer'] ?? false,
        'isOnline': true,
        'createdAt': data['createdAt'] ??
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return newMchatId;
  }

  // ===============================================================
  // VALIDATE MCHAT ID
  // ===============================================================

  bool _isValidMchatId(String id) {
    if (id.length != 8) {
      return false;
    }

    if (id == ownerMchatId) {
      return false;
    }

    final bool isNumeric =
        RegExp(r'^[0-9]+$').hasMatch(id);

    return isNumeric;
  }

  // ===============================================================
  // LOGIN
  // ===============================================================

  Future<void> login() async {
    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    // -------------------------------------------------------------
    // VALIDATION
    // -------------------------------------------------------------

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // -----------------------------------------------------------
      // FIREBASE LOGIN
      // -----------------------------------------------------------

      final UserCredential credential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user =
          credential.user;

      if (user == null) {
        throw Exception(
          'User account not found',
        );
      }

      // -----------------------------------------------------------
      // AUTOMATICALLY CREATE / REPAIR MCHAT ID
      // -----------------------------------------------------------

      final String mchatId =
          await _ensureMchatId(user);

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      // -----------------------------------------------------------
      // OPEN MCHAT HOME
      // -----------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              const MchatHomePage(),
        ),
        (route) => false,
      );

      // -----------------------------------------------------------
      // NOTE:
      // We do not show the ID popup for every login.
      // The ID is shown in Profile.
      // -----------------------------------------------------------

    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message =
          'Login failed';

      if (e.code == 'user-not-found') {
        message =
            'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message =
            'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        message =
            'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message =
            'Please enter a valid email';
      } else if (e.code == 'user-disabled') {
        message =
            'This account has been disabled';
      } else if (e.code == 'too-many-requests') {
        message =
            'Too many attempts. Please try again later';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF9FF),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFFFF9FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mchat Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 30),

              // =====================================================
              // LOGO
              // =====================================================

              Container(
                width: 100,
                height: 100,

                decoration: BoxDecoration(
                  color:
                      Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.chat_rounded,
                  size: 58,
                  color:
                      Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome to Mchat',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to continue',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              // =====================================================
              // EMAIL
              // =====================================================

              TextField(
                controller:
                    emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                textInputAction:
                    TextInputAction.next,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Email',

                  prefixIcon:
                      Icon(
                    Icons
                        .email_outlined,
                  ),

                  border:
                      OutlineInputBorder(),

                  filled: true,

                  fillColor:
                      Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // =====================================================
              // PASSWORD
              // =====================================================

              TextField(
                controller:
                    passwordController,

                obscureText:
                    obscurePassword,

                textInputAction:
                    TextInputAction.done,

                onSubmitted: (_) {
                  if (!isLoading) {
                    login();
                  }
                },

                decoration:
                    InputDecoration(
                  labelText:
                      'Password',

                  prefixIcon:
                      const Icon(
                    Icons
                        .lock_outline,
                  ),

                  border:
                      const OutlineInputBorder(),

                  filled: true,

                  fillColor:
                      Colors.white,

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // LOGIN BUTTON
              // =====================================================

              SizedBox(
                height: 54,

                child:
                    ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : login,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF673AB7,
                    ),

                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),

                  child:
                      isLoading
                          ? const SizedBox(
                              width: 25,
                              height: 25,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.5,

                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'LOGIN',

                              style:
                                  TextStyle(
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // REGISTER
              // =====================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Text(
                    "Don't have an account?",
                  ),

                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },

                    child: const Text(
                      'Register',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =====================================================
              // MCHAT ID INFORMATION
              // =====================================================

              Container(
                padding:
                    const EdgeInsets.all(16),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.deepPurple
                          .withValues(
                    alpha: 0.06,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),

                  border:
                      Border.all(
                    color:
                        Colors.deepPurple
                            .withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),

                child:
                    const Column(
                  children: [
                    Icon(
                      Icons.badge_rounded,
                      color:
                          Colors.deepPurple,
                      size: 32,
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Unique Mchat ID',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Every Mchat user gets a unique 8-digit numeric ID automatically.',
                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
