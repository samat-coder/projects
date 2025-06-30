import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedatabase/messagescreen.dart';
import 'package:firebasedatabase/profile.dart';
import 'package:firebasedatabase/signin.dart';
import 'package:flutter/material.dart';

class MyHomeScreen extends StatefulWidget {
  User? user;
  MyHomeScreen({super.key, required this.user});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  List<DocumentSnapshot>? allusers = [];
  List<DocumentSnapshot>? filtereduser;
  final TextEditingController _searchcontroller = TextEditingController();
  String? username;

  Future<void> getUserInfo() async {
    var document = await FirebaseFirestore.instance
        .collection("Person")
        .doc(widget.user!.uid)
        .get();

    setState(() {
      username = document["username"];
    });
  }

  void usersearch(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filtereduser = allusers;
      } else {
        filtereduser = allusers!
            .where((user) =>
                user["username"].toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(username ?? "loading......"),
          backgroundColor: Colors.blueAccent,
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == "profile") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyProfileScreen(user: widget.user!),
                        ));
                  } else if (value == "logout") {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MySignINScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: "profile",
                      child: Text("Profile"),
                    ),
                    PopupMenuItem(
                      value: "logout",
                      child: Text("Logout"),
                    ),
                  ];
                })
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _searchcontroller,
                  onChanged: (value) {
                    usersearch(value);
                  },
                  decoration: InputDecoration(
                      hintText: "search",
                      labelText: "who do you want to talk to?",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      fillColor: Colors.blueGrey),
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("Person").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  allusers = snapshot.data!.docs
                      .where((element) => element.id != widget.user!.uid)
                      .toList();
                  filtereduser ??= List.from(allusers!);
                  return ListView.builder(
                    itemCount: filtereduser!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => mymessagescreen(usersnapshop: filtereduser![index]),
                                ));
                          },
                          child: Card(
                            elevation: 3,
                            color: Colors.lightBlue[120],
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(
                                        filtereduser![index]["profilePic"]),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(filtereduser![index]["username"])
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ))
          ],
        ));
  }
}
