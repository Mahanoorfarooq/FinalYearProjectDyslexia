import 'package:dyslexify/Components/Drawer_navigation.dart';
import 'package:dyslexify/Pages/contact.dart';
import 'package:dyslexify/Pages/dyslexia.dart';
import 'package:dyslexify/Pages/faq.dart';
import 'package:dyslexify/Pages/frontpage.dart';
import 'package:dyslexify/Pages/handwritten.dart';
import 'package:dyslexify/Pages/home.dart';
import 'package:dyslexify/Pages/login.dart';
import 'package:dyslexify/Pages/mri.dart';
import 'package:dyslexify/Pages/profile.dart';
import 'package:dyslexify/Pages/reports.dart';
import 'package:dyslexify/Pages/sign.dart';
import 'package:dyslexify/Pages/splash.dart';
import 'package:dyslexify/Pages/about.dart';
import 'package:dyslexify/Pages/tips.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dyslexify/pages/identify.dart' as identify;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF335e96),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        fontFamily: 'OpenDyslexic',
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFFFFFAE6),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/contact': (context) => const ContactScreen(),
        '/main': (context) => const MainScreen(),
        '/signUp': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/dyslexia': (context) => const DyslexiaInfoPage(),
        '/uploadHandwriting': (context) => const HandwrittenImagePage(),
        '/uploadmri': (context) => const MriImagePage(),
        '/profile': (context) => const ProfilePage(),
        '/reports': (context) => ReportsPage(),
        '/about': (context) => AboutPage(),
        '/welcome': (context) => WelcomePage(),
        '/faq': (context) => FaqPage(),
        '/identifyDyslexia': (context) => identify.IdentifyDyslexiaPage(),
        '/tips': (context) => DyslexiaTipsPage()
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const ContactScreen(),
    const Placeholder(), // You can replace this with actual screens later
  ];

  void _onItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/reports');
        break;
      case 2:
        Navigator.pushNamed(context, '/about');
        break;
      case 3:
        Navigator.pushNamed(context, '/contact');
        break;
      case 4:
        Navigator.pushNamed(context, '/faq');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF335e96),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: CustomDrawer(onItemSelected: _onItemSelected),
      body: _tabs[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
