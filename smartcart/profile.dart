import 'package:bookapp/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isUserLoggedIn = user != null;
    });

    if (_isUserLoggedIn) {
      _loadUserData();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _isUserLoggedIn = false;

      // Clear all the controllers when logged out
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      _pincodeController.clear();
      _phoneController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _addressController.text = data['address'] ?? '';
          _cityController.text = data['city'] ?? '';
          _pincodeController.text = data['pincode'] ?? '';
          _phoneController.text = data['mobile'] ?? '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'mobile': _phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }

    setState(() => _isLoading = false);
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Edit Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple[500],
        actions: _isUserLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout,color: Colors.white,),
                  tooltip: 'Logout',
                  onPressed: _logout,
                )
              ]
            : null,
      ),
      backgroundColor: Colors.blue.shade50,
      body: _isUserLoggedIn
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildTextField(
                      _nameController,
                      "Full Name",
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                    ),
                    buildTextField(
                      _addressController,
                      "Address",
                      maxLines: 2,
                      validator: (val) => val!.isEmpty ? "Enter address" : null,
                    ),
                    buildTextField(
                      _cityController,
                      "City",
                      validator: (val) => val!.isEmpty ? "Enter city" : null,
                    ),
                    buildTextField(
                      _pincodeController,
                      "Pincode",
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter pincode";
                        if (!RegExp(r'^\d{6}$').hasMatch(val)) {
                          return "6-digit required";
                        }
                        return null;
                      },
                    ),
                    buildTextField(
                      _phoneController,
                      "Phone",
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter phone";
                        if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                          return "10-digit required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(fontSize: 18,color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'You are not logged in',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ).then((value) {
                        // Check login status again after coming back from Login screen
                        _checkLoginStatus();
                      });
                    },
                    child: const Text("Login Now"),
                  ),
                ],
              ),
            ),
    );
  }
}
