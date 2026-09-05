import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'mchat_id_service.dart';
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
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

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
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception(
          'User account not found',
        );
      }

      // -----------------------------------------------------------
      // GET DISPLAY NAME
      // -----------------------------------------------------------

      String name = user.displayName ?? '';

      if (name.isEmpty) {
        name = 'Mchat User';
      }

      // -----------------------------------------------------------
      // AUTOMATIC MCHAT ID
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

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MchatHomePage(),
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

      String message = 'Login failed';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
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
    const Color royalGold = Color(0xFFFFD35A);
    const Color brightGold = Color(0xFFFFB300);
    const Color royalPurple = Color(0xFF6A1B9A);
    const Color darkPurple = Color(0xFF24002F);
    const Color darkText = Color(0xFF21152A);
    const Color softText = Color(0xFF6F6575);

    return Scaffold(
      backgroundColor: darkPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF16001F),
              Color(0xFF2A0038),
              Color(0xFF4A1163),
              Color(0xFF120018),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              12,
              22,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // =================================================
                // TOP ROYAL HEADER
                // =================================================

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 2,
                      decoration: BoxDecoration(
                        color: royalGold,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: royalGold,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 38,
                      height: 2,
                      decoration: BoxDecoration(
                        color: royalGold,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'MCHAT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: royalGold,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'ROYAL SOCIAL WORLD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFE8A3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // ROYAL CROWN
                // =================================================

                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFFE9A6),
                          Color(0xFFFFC107),
                          Color(0xFF7B3F00),
                        ],
                      ),
                      border: Border.all(
                        color: royalGold,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: royalGold.withValues(
                            alpha: 0.45,
                          ),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF3A1600),
                        size: 68,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // WELCOME
                // =================================================

                const Text(
                  'Welcome to Mchat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Login to enter the Royal World',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD978),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // ROYAL CARD
                // =================================================

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFDF7E7),
                        Color(0xFFFFFDF7),
                      ],
                    ),
                    border: Border.all(
                      color: royalGold,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // =========================================
                      // EMAIL
                      // =========================================

                      TextField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: royalPurple,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText:
                              'Enter your email',
                          labelStyle:
                              const TextStyle(
                            color: softText,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          floatingLabelStyle:
                              const TextStyle(
                            color: royalPurple,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          hintStyle:
                              const TextStyle(
                            color: Color(0xFFAAA0AE),
                          ),
                          prefixIcon:
                              const Icon(
                            Icons.email_rounded,
                            color: brightGold,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(0xFFE3D9E8),
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(0xFFE3D9E8),
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color: brightGold,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =========================================
                      // PASSWORD
                      // =========================================

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
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: royalPurple,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText:
                              'Enter your password',
                          labelStyle:
                              const TextStyle(
                            color: softText,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          floatingLabelStyle:
                              const TextStyle(
                            color: royalPurple,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          hintStyle:
                              const TextStyle(
                            color: Color(0xFFAAA0AE),
                          ),
                          prefixIcon:
                              const Icon(
                            Icons.lock_rounded,
                            color: brightGold,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                            color: brightGold,
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_rounded
                                  : Icons
                                      .visibility_off_rounded,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(0xFFE3D9E8),
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(0xFFE3D9E8),
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            borderSide:
                                const BorderSide(
                              color: brightGold,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =========================================
                      // LOGIN BUTTON
                      // =========================================

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF8E24AA),
                                Color(0xFF5E1A8A),
                                Color(0xFF3A0D58),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              30,
                            ),
                            border: Border.all(
                              color: royalGold,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: royalGold
                                    .withValues(
                                  alpha: 0.30,
                                ),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : login,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.transparent,
                              shadowColor:
                                  Colors.transparent,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  Colors.transparent,
                              disabledForegroundColor:
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
                                      strokeWidth: 2.5,
                                      color:
                                          royalGold,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .workspace_premium_rounded,
                                        color:
                                            royalGold,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'LOGIN',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.w900,
                                          letterSpacing:
                                              1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================================
                      // REGISTER
                      // =========================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: darkText,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
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
                              style: TextStyle(
                                color: royalPurple,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // UNIQUE MCHAT ID
                // =================================================

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(22),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF351044),
                        Color(0xFF1D0827),
                      ],
                    ),
                    border: Border.all(
                      color: royalGold
                          .withValues(alpha: 0.70),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: royalGold
                            .withValues(alpha: 0.12),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .workspace_premium_rounded,
                        color: royalGold,
                        size: 38,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'UNIQUE MCHAT ID',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: royalGold,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Every Mchat user gets a unique 8-digit numeric ID automatically.',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // ROYAL FOOTER
                // =================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 1,
                      color: royalGold,
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.star_rounded,
                      color: royalGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ENTER THE ROYAL WORLD',
                      style: TextStyle(
                        color: Color(0xFFFFD978),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.star_rounded,
                      color: royalGold,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 25,
                      height: 1,
                      color: royalGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
