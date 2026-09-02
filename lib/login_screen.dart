import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'inbox_screen.dart';
import 'profile_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  static const String ownerMchatId = '11111111';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<String> _generateUniqueMchatId() async {
    final random = Random.secure();

    while (true) {
      final number = 10000000 + random.nextInt(90000000);
      final id = number.toString();

      if (id == ownerMchatId) {
        continue;
      }

      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('mchatId', isEqualTo: id)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        return id;
      }
    }
  }

  Future<String?> _ensureMchatId(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      final mchatId = await _generateUniqueMchatId();

      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? 'Mchat User',
        'email': user.email ?? '',
        'mchatId': mchatId,
        'coins': 0,
        'vipLevel': 0,
        'isOwner': false,
        'isVolunteer': false,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return mchatId;
    }

    final data = snapshot.data() ?? <String, dynamic>{};

    final isOwner =
        data['isOwner'] == true || data['role'] == 'owner';

    final existingId =
        data['mchatId']?.toString().trim() ?? '';

    if (isOwner) {
      if (existingId != ownerMchatId) {
        await userRef.update({
          'mchatId': ownerMchatId,
          'isOnline': true,
        });

        return ownerMchatId;
      }

      await userRef.update({
        'isOnline': true,
      });

      return null;
    }

    if (existingId.isEmpty) {
      final mchatId = await _generateUniqueMchatId();

      await userRef.update({
        'mchatId': mchatId,
        'isOnline': true,
      });

      return mchatId;
    }

    await userRef.update({
      'isOnline': true,
    });

    return null;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        final newMchatId = await _ensureMchatId(user);

        if (!mounted) return;

        if (newMchatId != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text(
                  '🎉 Your Mchat ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your unique Mchat ID is',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.deepPurple.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Text(
                        newMchatId,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Save this number.\n'
                      'You can use it to find friends.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('CONTINUE'),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MchatHomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }

      showMessage(message);
    } catch (e) {
      showMessage('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mchat'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 35),

              const Icon(
                Icons.chat_bubble_rounded,
                size: 90,
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome to Mchat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon:
                      Icon(Icons.email_outlined),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText:
                      'Enter your password',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  border:
                      const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      loading ? null : login,
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                  ),
                  TextButton(
                    onPressed: loading
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
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MchatHomePage extends StatefulWidget {
  const MchatHomePage({super.key});

  @override
  State<MchatHomePage> createState() =>
      _MchatHomePageState();
}

class _MchatHomePageState
    extends State<MchatHomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    InboxScreen(),
    Center(
      child: Text(
        'Live',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            selectedIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.chat_outlined,
            ),
            selectedIcon: Icon(
              Icons.chat,
            ),
            label: 'Inbox',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.live_tv_outlined,
            ),
            selectedIcon: Icon(
              Icons.live_tv,
            ),
            label: 'Live',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
