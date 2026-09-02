import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'home_screen.dart';
import 'inbox_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'live_screen.dart';


// ============================================================================
// MAIN
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MchatApp());
}


// ============================================================================
// MCHAT APP
// ============================================================================

class MchatApp extends StatelessWidget {
  const MchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Mchat',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B3FE4),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFFFF9FF),
      ),

      home: const LoginScreen(),
    );
  }
}


// ============================================================================
// MCHAT HOME PAGE
// ============================================================================

class MchatHomePage extends StatefulWidget {
  const MchatHomePage({super.key});

  @override
  State<MchatHomePage> createState() =>
      _MchatHomePageState();
}


class _MchatHomePageState
    extends State<MchatHomePage> {

  int selectedIndex = 0;


  // ==========================================================================
  // APP PAGES
  // ==========================================================================

  final List<Widget> pages = const [

    // HOME
    HomeScreen(),

    // INBOX
    InboxScreen(),

    // LIVE
    LiveScreen(),

    // PROFILE
    ProfileScreen(),
  ];


  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[selectedIndex],


      // ======================================================================
      // BOTTOM NAVIGATION
      // ======================================================================

      bottomNavigationBar: NavigationBar(

        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {

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
