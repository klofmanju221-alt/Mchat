import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mchat_id_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // REGISTER
  // ===============================================================

  Future<void> register() async {
    final String name =
        nameController.text.trim();

    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill all fields'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters',
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
      // CREATE FIREBASE ACCOUNT
      // -----------------------------------------------------------

      final UserCredential credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user =
          credential.user;

      if (user == null) {
        throw Exception(
          'User account could not be created',
        );
      }

      // -----------------------------------------------------------
      // SAVE DISPLAY NAME
      // -----------------------------------------------------------

      await user.updateDisplayName(name);

      // -----------------------------------------------------------
      // AUTOMATIC MCHAT ID
      // -----------------------------------------------------------

      final String mchatId =
          await MchatIdService.ensureMchatId(
        user: user,
        name: name,
        email: email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      // -----------------------------------------------------------
      // SHOW ID IMMEDIATELY
      // -----------------------------------------------------------

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              '🎉 Registration Successful',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Your unique Mchat ID is',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .deepPurple
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Text(
                    mchatId,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 3,
                      color:
                          Colors.deepPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Save this ID.\n'
                  'You can use it to find friends.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                      const Text(
                    'CONTINUE',
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      // Return to Login.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message =
          'Registration failed';

      if (e.code ==
          'email-already-in-use') {
        message =
            'This email is already registered';
      } else if (e.code ==
          'invalid-email') {
        message =
            'Please enter a valid email address';
      } else if (e.code ==
          'weak-password') {
        message =
            'Password is too weak';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            'Registration failed: $e',
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
          'Create Account',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.person_add_alt_1,
                size: 70,
                color:
                    Colors.deepPurple,
              ),

              const SizedBox(height: 16),

              const Text(
                'Join Mchat',
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
                'Create your account and get your unique Mchat ID',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    nameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                  prefixIcon:
                      Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      Colors.white,
                ),
              ),

              const SizedBox(height: 16),

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
                  labelText: 'Email',
                  prefixIcon:
                      Icon(
                    Icons.email_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    passwordController,
                obscureText:
                    obscurePassword,
                textInputAction:
                    TextInputAction.done,
                onSubmitted: (_) {
                  if (!isLoading) {
                    register();
                  }
                },
                decoration:
                    InputDecoration(
                  labelText:
                      'Password',
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
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

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child:
                    ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : register,
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
                  child: isLoading
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
                          'REGISTER',
                          style:
                              TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

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
                    SizedBox(height: 8),
                    Text(
                      'Unique Mchat ID',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'An 8-digit numeric ID will be created automatically.',
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
