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
  final _auth = FirebaseAuth.instance;
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

  User? get user => _auth.currentUser;
  bool _isLoading = false;

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
      setState(() => _isLoading = true);

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
          email = user!.email ?? '';
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> pickImage() async {
    if (user == null) return;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      setState(() => _isLoading = true);

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

      await saveProfileLocally();
    } catch (e) {
      showError("Error uploading image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    if (user == null) return;

    try {
      setState(() => _isLoading = true);

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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      showError("Error updating profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (user?.email == null) return;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => const ResetPasswordDialog(),
    );
  }

  Future<void> deleteAccount() async {
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text(
            "Confirm Account Deletion",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to permanently delete your account?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  setState(() => _isLoading = true);

                  await _firestore.collection('users').doc(user!.uid).delete();
                  await user!.delete();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  if (!mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                } catch (e) {
                  showError("Error deleting account: $e");
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Delete Account",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Logout', style: TextStyle(fontSize: 16)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      try {
        setState(() => _isLoading = true);
        await saveProfileLocally();
        await _auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        showError("Error during logout: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'LogOut',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        onItemSelected: (index) {
          Navigator.pop(context);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(
                              0.3), // Increased opacity from 0.1 to 0.3
                          spreadRadius: 3, // Increased from 2
                          blurRadius: 15, // Increased from 10
                          offset: const Offset(
                              0, 5), // Increased Y offset from 3 to 5
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: user != null ? pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                                backgroundColor: Colors.grey[200],
                                child: imageProvider == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              if (user != null)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xFF335e96),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(
                              0.3), // Increased opacity from 0.1 to 0.3
                          spreadRadius: 3, // Increased from 2
                          blurRadius: 15, // Increased from 10
                          offset: const Offset(
                              0, 5), // Increased Y offset from 3 to 5
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          enabled: user != null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone,
                          enabled: user != null,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: addressController,
                          label: "Address",
                          icon: Icons.location_city,
                          enabled: user != null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: roleController,
                          label: "Role (Student, Teacher, etc)",
                          icon: Icons.work_outline,
                          enabled: user != null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons
                  if (user != null) ...[
                    SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF335e96),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      onTap: resetPassword,
                      leading: const Icon(Icons.lock_reset,
                          color: Color(0xFF335e96)),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Color(0xFF335e96),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: deleteAccount,
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      keyboardType: keyboardType,
    );
  }
}

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Verify passwords match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        throw Exception('Passwords do not match');
      }

      // Update password in Firebase
      await user.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'requires-recent-login':
          return 'This operation is sensitive and requires recent authentication. Please log out and log in again before changing your password.';
        case 'weak-password':
          return 'The password is too weak. Please choose a stronger password.';
        default:
          return error.message ?? 'An unknown error occurred';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Change Password', style: TextStyle(fontSize: 16)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF335e96),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
