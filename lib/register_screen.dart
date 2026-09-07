import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mchat_id_service.dart';
import 'premium_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController referralController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    referralController.dispose();
    super.dispose();
  }

  // ===============================================================
  // REGISTER
  // ===============================================================

  Future<void> register() async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    final String referralCode =
        referralController.text.trim().toUpperCase();

    // ============================================================
    // BASIC VALIDATION
    // ============================================================

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showMessage(
        'Please fill all required fields.',
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

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    // ============================================================
    // REFERRAL CODE FORMAT
    // ============================================================

    if (referralCode.isNotEmpty &&
        !RegExp(r'^MCHAT-[0-9]{8}$')
            .hasMatch(referralCode)) {
      _showMessage(
        'Invalid referral code. Example: MCHAT-12345678',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    User? createdUser;

    try {
      // ==========================================================
      // CREATE FIREBASE AUTH ACCOUNT
      // ==========================================================

      final UserCredential credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      createdUser = credential.user;

      if (createdUser == null) {
        throw Exception(
          'User account could not be created.',
        );
      }

      // ==========================================================
      // SAVE DISPLAY NAME
      // ==========================================================

      await createdUser.updateDisplayName(name);

      // ==========================================================
      // REFERRAL VERIFICATION
      //
      // IMPORTANT:
      // We do NOT search the users collection here.
      //
      // We use mchatIds/{8-digit-id}.
      // This works with our secure Firestore rules.
      // ==========================================================

      String? referredByUid;
      String? referredByCode;

      if (referralCode.isNotEmpty) {
        final String referredMchatId =
            referralCode.substring(6);

        // --------------------------------------------------------
        // Validate Mchat ID
        // --------------------------------------------------------

        if (!MchatIdService.isValidMchatId(
          referredMchatId,
        )) {
          _showMessage(
            'Invalid referral Mchat ID.',
            isError: true,
          );

          await _cleanupNewAuthUser(
            createdUser,
          );

          return;
        }

        // --------------------------------------------------------
        // Find referrer through Mchat ID index
        // --------------------------------------------------------

        final DocumentSnapshot<Map<String, dynamic>>
            referralSnapshot =
            await FirebaseFirestore.instance
                .collection('mchatIds')
                .doc(referredMchatId)
                .get();

        if (!referralSnapshot.exists) {
          _showMessage(
            'Referral code not found. Please check the code.',
            isError: true,
          );

          await _cleanupNewAuthUser(
            createdUser,
          );

          return;
        }

        final Map<String, dynamic> referralIndex =
            referralSnapshot.data() ??
                <String, dynamic>{};

        final String foundUid =
            referralIndex['uid']?.toString() ?? '';

        // --------------------------------------------------------
        // Self referral protection
        // --------------------------------------------------------

        if (foundUid.isEmpty ||
            foundUid == createdUser.uid) {
          _showMessage(
            'Self-referral is not allowed.',
            isError: true,
          );

          await _cleanupNewAuthUser(
            createdUser,
          );

          return;
        }

        referredByUid = foundUid;
        referredByCode = referralCode;
      }

      // ==========================================================
      // CREATE / SAVE MCHAT PROFILE
      //
      // Referral information is included during initial
      // profile creation.
      //
      // NO COINS ARE CREDITED HERE.
      // ==========================================================

      final String mchatId =
          await MchatIdService.ensureMchatId(
        user: createdUser,
        name: name,
        email: email,
        referredByUid: referredByUid,
        referredByCode: referredByCode,
      );

      // ==========================================================
      // SEND EMAIL VERIFICATION
      // ==========================================================

      await createdUser.sendEmailVerification();

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      // ==========================================================
      // SUCCESS DIALOG
      // ==========================================================

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: PremiumTheme.gold,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Registration Successful',
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your unique Mchat ID is',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // MCHAT ID
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          PremiumTheme.purpleGradient,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: PremiumTheme.gold
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      mchatId,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PremiumTheme.gold,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Save this ID.\n'
                    'You can use it to find friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // EMAIL VERIFICATION MESSAGE
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: PremiumTheme.gold
                          .withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: PremiumTheme.gold
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mark_email_read_rounded,
                          color: PremiumTheme.gold,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'A verification email has been sent to your email address. Please verify your email before logging in.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // REFERRAL PENDING MESSAGE
                  // ------------------------------------------------

                  if (referredByCode != null) ...[
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: PremiumTheme.purple
                            .withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: PremiumTheme.gold
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            color: PremiumTheme.gold,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Referral received and is pending backend verification. The 1000 Coins reward will not be credited until verification is completed.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      PremiumTheme.premiumButton(),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
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

      // ==========================================================
      // SIGN OUT
      //
      // User must verify email and login again.
      // ==========================================================

      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message = 'Registration failed.';

      if (e.code == 'email-already-in-use') {
        message =
            'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message =
            'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message =
            'Password is too weak.';
      } else if (e.code == 'operation-not-allowed') {
        message =
            'Email registration is not enabled in Firebase.';
      } else if (e.code == 'network-request-failed') {
        message =
            'Network error. Please check your internet connection.';
      } else if (e.code == 'too-many-requests') {
        message =
            'Too many attempts. Please try again later.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Firebase error: ${e.message ?? 'Please try again.'}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Registration failed. Please try again.',
        isError: true,
      );
    }
  }

  // ===============================================================
  // CLEANUP AUTH USER
  // ===============================================================

  Future<void> _cleanupNewAuthUser(
    User? user,
  ) async {
    try {
      if (user != null) {
        await user.delete();
      }
    } catch (_) {
      // Ignore cleanup failure.
      // The main error message has already been shown.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError
              ? Colors.red.shade800
              : PremiumTheme.surface2,
          behavior: SnackBarBehavior.floating,
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

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            35,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.purpleGradient,
                  borderRadius:
                      BorderRadius.circular(25),
                  border: Border.all(
                    color: PremiumTheme.gold
                        .withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.purple
                          .withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    PremiumTheme.iconBox(
                      Icons.person_add_alt_1_rounded,
                      size: 70,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Join Mchat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Create your account and get your unique Mchat ID',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // =====================================================
              // NAME
              // =====================================================

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
                controller: nameController,
                textCapitalization:
                    TextCapitalization.words,
                textInputAction:
                    TextInputAction.next,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(
                    Icons.person_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // EMAIL
              // =====================================================

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
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // PASSWORD
              // =====================================================

              const Text(
                'Password',
                style: TextStyle(
                  color: PremiumTheme.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction:
                    TextInputAction.next,
                onSubmitted: (_) {
                  if (!isLoading) {
                    register();
                  }
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText:
                      'Minimum 6 characters',
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // REFERRAL CODE
              // =====================================================

              const Text(
                'Referral Code (Optional)',
                style: TextStyle(
                  color: PremiumTheme.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: referralController,
                textCapitalization:
                    TextCapitalization.characters,
                textInputAction:
                    TextInputAction.done,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Referral Code',
                  hintText: 'MCHAT-12345678',
                  prefixIcon: Icon(
                    Icons.card_giftcard_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'If someone invited you, enter their referral code.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // REGISTER BUTTON
              // =====================================================

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  style:
                      PremiumTheme.premiumButton(),
                  onPressed:
                      isLoading ? null : register,
                  icon: Icon(
                    isLoading
                        ? Icons.hourglass_top_rounded
                        : Icons.person_add_alt_1_rounded,
                  ),
                  label: Text(
                    isLoading
                        ? 'Creating Account...'
                        : 'CREATE ACCOUNT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =====================================================
              // MCHAT ID INFORMATION
              // =====================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration:
                    PremiumTheme.premiumCard(
                  radius: 20,
                ),
                child: Column(
                  children: [
                    PremiumTheme.iconBox(
                      Icons.badge_rounded,
                      size: 52,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Unique Mchat ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'An 8-digit Mchat ID will be created automatically after registration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // SECURITY INFORMATION
              // =====================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PremiumTheme.surface,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: PremiumTheme.gold
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: PremiumTheme.gold,
                      size: 23,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Referral rewards are never created or credited by this screen. Referral information is sent to the secure backend for verification.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.4,
                        ),
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
