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

    // Referral code is optional.
    // If entered, it must follow the MCHAT-XXXXXXXX format.
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

    try {
      // ===========================================================
      // VERIFY REFERRAL CODE BEFORE ACCOUNT CREATION
      // ===========================================================

      String? referredByUid;
      String? referredByCode;

      if (referralCode.isNotEmpty) {
        final QuerySnapshot<Map<String, dynamic>> referralQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .where(
                  'referralCode',
                  isEqualTo: referralCode,
                )
                .limit(1)
                .get();

        if (referralQuery.docs.isEmpty) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showMessage(
            'Referral code not found. Please check the code.',
            isError: true,
          );
          return;
        }

        final String foundUid =
            referralQuery.docs.first.id;

        referredByUid = foundUid;
        referredByCode = referralCode;
      }

      // ===========================================================
      // CREATE FIREBASE ACCOUNT
      // ===========================================================

      final UserCredential credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception(
          'User account could not be created.',
        );
      }

      // ===========================================================
      // SAVE DISPLAY NAME
      // ===========================================================

      await user.updateDisplayName(name);

      // ===========================================================
      // AUTOMATIC MCHAT ID
      // ===========================================================

      final String mchatId =
          await MchatIdService.ensureMchatId(
        user: user,
        name: name,
        email: email,
      );

      // ===========================================================
      // SAVE REFERRAL INFORMATION
      // ===========================================================

      final DocumentReference<Map<String, dynamic>> userRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);

      final Map<String, dynamic> referralData =
          <String, dynamic>{
        'referralCode': 'MCHAT-$mchatId',
        'successfulReferrals': 0,
        'referralCoins': 0,
        'referralUpdatedAt':
            FieldValue.serverTimestamp(),
      };

      if (referredByUid != null &&
          referredByCode != null) {
        referralData['referredByUid'] =
            referredByUid;

        referralData['referredByCode'] =
            referredByCode;

        referralData['referralStatus'] =
            'pending';

        referralData['referredAt'] =
            FieldValue.serverTimestamp();
      }

      await userRef.set(
        referralData,
        SetOptions(merge: true),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      // ===========================================================
      // REGISTRATION SUCCESS DIALOG
      // ===========================================================

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
            content: Column(
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

                if (referredByCode != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(12),
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
                      children: [
                        Icon(
                          Icons.card_giftcard_rounded,
                          color: PremiumTheme.gold,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Referral received and pending verification.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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

      // Return to Login.
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
        message = 'Password is too weak.';
      } else if (e.code == 'operation-not-allowed') {
        message =
            'Email registration is not enabled.';
      } else if (e.code == 'network-request-failed') {
        message =
            'Network error. Please try again.';
      }

      _showMessage(
        message,
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
  // MESSAGE
  // ===============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
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
                          ? Icons
                              .visibility_rounded
                          : Icons
                              .visibility_off_rounded,
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
              // REFERRAL INFORMATION
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
                        'Referral rewards are not created or credited by this screen. Referral information is saved for backend verification.',
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
