import 'package:bookapp/login.dart';
import 'package:bookapp/navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text,
            );

        User? user = userCredential.user;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
              'uid': user.uid,
              'name': nameController.text.trim(),
              'mobile': mobileController.text.trim(),
              'address': addressController.text.trim(),
              'city': cityController.text.trim(),
              'pincode': pincodeController.text.trim(),
              'email': emailController.text.trim(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User Registered Successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void skipSignUp() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => mynavigation()),
    );
  }

  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/949587/pexels-photo-949587.jpeg?auto=compress&cs=tinysrgb&w=600',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)), // Dark overlay

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Updated Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          0.4,
                        ), // ✅ Same style as Login
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: inputDecoration('Name'),
                              style: TextStyle(color: Colors.white),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter name' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: mobileController,
                              decoration: inputDecoration('Mobile'),
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter mobile' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: addressController,
                              decoration: inputDecoration('Address'),
                              style: TextStyle(color: Colors.white),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter address' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: cityController,
                              decoration: inputDecoration('City'),
                              style: TextStyle(color: Colors.white),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter city' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: pincodeController,
                              decoration: inputDecoration('Pincode'),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.white),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter pincode' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: emailController,
                              decoration: inputDecoration('Email'),
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white),
                              validator:
                                  (value) =>
                                      value!.isEmpty ? 'Enter email' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              decoration: inputDecoration('Password'),
                              style: TextStyle(color: Colors.white),
                              obscureText: true,
                              validator:
                                  (value) =>
                                      value!.length < 6
                                          ? 'Min 6 characters'
                                          : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
TextButton(
  onPressed: goToLogin,
  child: const Text(
    "Already have an account? Login",
    style: TextStyle(color: Colors.white70),
  ),
),
TextButton(
  onPressed: skipSignUp,
  child: const Text(
    "Skip >>",
    style: TextStyle(color: Colors.white70),
  ),
),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
