import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexify/Components/Drawer_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  int _currentIndex = 2;

  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String role = '';
  String? imageBase64;
  File? _imageFile;
  Uint8List? _webImage;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController roleController;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    roleController = TextEditingController();
    fetchUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    roleController.dispose();
    super.dispose();
  }

  // Save profile data locally so it can be shown after logout
  Future<void> saveProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('email', email);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('role', roleController.text);
    if (imageBase64 != null) {
      await prefs.setString('imageBase64', imageBase64!);
    }
  }

  // Load profile data locally (if user logged out)
  Future<void> loadProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      phone = prefs.getString('phone') ?? '';
      address = prefs.getString('address') ?? '';
      role = prefs.getString('role') ?? '';
      imageBase64 = prefs.getString('imageBase64');
      nameController.text = name;
      phoneController.text = phone;
      addressController.text = address;
      roleController.text = role;
    });
  }

  Future<void> fetchUserProfile() async {
    if (user == null) {
      await loadProfileLocally();
      return;
    }

    try {
      final profileDataDoc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('profile')
          .doc('profileData')
          .get();

      final photoDoc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('profile')
          .doc('photo')
          .get();

      if (profileDataDoc.exists) {
        final data = profileDataDoc.data()!;
        setState(() {
          name = data['username'] ?? '';
          email = user!.email ?? ''; // fallback to Firebase email
          phone = data['phone'] ?? '';
          address = data['address'] ?? '';
          role = data['role'] ?? '';
          nameController.text = name;
          phoneController.text = phone;
          addressController.text = address;
          roleController.text = role;
        });
      }

      if (photoDoc.exists) {
        final imageData = photoDoc.data();
        setState(() {
          imageBase64 = imageData?['imageBase64'];
        });
      }
    } catch (e) {
      showError("Error fetching profile: $e");
    }
  }

  Future<void> pickImage() async {
    if (user == null) return;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          imageBase64 = base64Encode(bytes);
        });
      } else {
        final file = File(pickedFile.path);
        if (!mounted) return;
        final bytes = await file.readAsBytes();
        setState(() {
          _imageFile = file;
          imageBase64 = base64Encode(bytes);
        });
      }

      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('profile')
          .doc('photo')
          .set({'imageBase64': imageBase64});

      // Update local storage too
      await saveProfileLocally();
    } catch (e) {
      showError("Error uploading image: $e");
    }
  }

  Future<void> updateProfile() async {
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('profile')
          .doc('profileData')
          .set({
        'username': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'role': roleController.text,
      });

      await saveProfileLocally();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } catch (e) {
      showError("Error updating profile: $e");
    }
  }

  Future<void> deleteAccount() async {
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('users').doc(user!.uid).delete();
                await user!.delete();

                // Clear local storage on deletion
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } catch (e) {
                showError("Error deleting account: $e");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageBase64 != null) {
      try {
        final decodedBytes = base64Decode(imageBase64!);
        imageProvider = MemoryImage(decodedBytes);
      } catch (e) {
        imageProvider = null;
      }
    }

    if (imageProvider == null) {
      if (kIsWeb) {
        imageProvider = _webImage != null ? MemoryImage(_webImage!) : null;
      } else {
        imageProvider = _imageFile != null ? FileImage(_imageFile!) : null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bio–data', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await saveProfileLocally();
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;

              await fetchUserProfile();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          )
        ],
      ),
      drawer: CustomDrawer(
        onItemSelected: (index) {
          Navigator.pop(context); // Close drawer
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
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap:
                  user != null ? pickImage : null, // Disable pick if logged out
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageProvider,
                backgroundColor: const Color(0xFFcccccc),
                child: imageProvider == null
                    ? const Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              enabled: user != null,
              decoration: const InputDecoration(
                labelText: "What's your first name?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              enabled: user != null,
              decoration: const InputDecoration(
                labelText: "Phone number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              enabled: user != null,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleController,
              enabled: user != null,
              decoration: const InputDecoration(
                labelText: "Role (Student, Teacher, etc)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 30),
            if (user != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF335e96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            const SizedBox(height: 16),
            if (user != null)
              TextButton(
                onPressed: deleteAccount,
                child: const Text(
                  'Delete my account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
