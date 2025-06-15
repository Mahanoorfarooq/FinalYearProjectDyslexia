import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _login(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  void _signUp(BuildContext context) {
    Navigator.pushNamed(context, '/signUp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top illustration
                Image.asset(
                  'assets/images/child.png',
                  height: 220,
                ),
                const SizedBox(height: 20),

                // Welcome text
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome to",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),

                // App Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🧠 Dyslexify",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF335e96),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "Too often we overlook the signs of dyslexia. At Dyslexify, we help you identify, understand, and embrace learning differences. Join us to create a more inclusive future with AI-driven insights into dyslexia.",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 32),

                // Login Button with icon
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF335e96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () => _login(context),
                ),
                const SizedBox(height: 12),

                // Sign Up Button with icon
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF335e96), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.person_add, color: Color(0xFF335e96)),
                  label: const Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Color(0xFF335e96),
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _signUp(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
