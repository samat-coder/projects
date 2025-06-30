import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedatabase/homescreen.dart';
import 'package:flutter/material.dart';

class MyProfileScreen extends StatefulWidget {
  final User user;
  const MyProfileScreen({super.key, required this.user});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  String? profilePic = "";

  Future<void> getUserInfo() async {
    var result = await FirebaseFirestore.instance
        .collection("Person")
        .doc(widget.user.uid)
        .get();

    setState(() {
      _nameController.text = result["username"];
      _emailController.text = result["email"];
      _cityController.text = result["city"];
      _mobileController.text = result["mobile"];
      _genderController.text = result["gender"];
      profilePic = result["profilePic"];
    });
  }

  Future<void> updateInfo() async {
    await FirebaseFirestore.instance.collection("Person").doc(widget.user.uid).update({
      "username": _nameController.text.trim(),
      "city": _cityController.text.trim(),
      "mobile": _mobileController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomeScreen(user: widget.user)),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePic ??"loading...."),
              ),
              const SizedBox(height: 20),
              Text(
                "Update Your Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your name",
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  hintText: "Enter your city",
                  prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: "Mobile",
                  hintText: "Enter your mobile number",
                  prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _genderController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Gender",
                  hintText: "Gender",
                  prefixIcon: Icon(Icons.people, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: updateInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
