import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'mchat_id_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // LOGIN
  // ===============================================================

  Future<void> login() async {
    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
      // GET DISPLAY NAME
      // -----------------------------------------------------------

      String name =
          user.displayName ??
              '';

      if (name.isEmpty) {
        name = 'Mchat User';
      }

      // -----------------------------------------------------------
      // AUTOMATIC MCHAT ID
      //
      // Existing user:
      //     keep same ID.
      //
      // Old user without ID:
      //     create new ID automatically.
      //
      // Owner:
      //     11111111
      // -----------------------------------------------------------

      await MchatIdService.ensureMchatId(
        user: user,
        name: name,
        email: user.email ?? email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      // -----------------------------------------------------------
      // OPEN HOME
      // -----------------------------------------------------------

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              const MchatHomePage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message =
          'Login failed';

      if (e.code ==
          'user-not-found') {
        message =
            'No account found with this email';
      } else if (e.code ==
          'wrong-password') {
        message =
            'Incorrect password';
      } else if (e.code ==
          'invalid-credential') {
        message =
            'Invalid email or password';
      } else if (e.code ==
          'invalid-email') {
        message =
            'Please enter a valid email';
      } else if (e.code ==
          'user-disabled') {
        message =
            'This account has been disabled';
      } else if (e.code ==
          'too-many-requests') {
        message =
            'Too many attempts. Please try again later';
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
            fontWeight:
                FontWeight.bold,
            fontSize: 24,
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
              const SizedBox(height: 30),

              Container(
                width: 100,
                height: 100,
                decoration:
                    BoxDecoration(
                  color: Colors
                      .deepPurple
                      .shade50,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
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
                          'LOGIN',
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
                                    builder:
                                        (_) =>
                                            const RegisterScreen(),
                                  ),
                                );
                              },
                    child:
                        const Text(
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
