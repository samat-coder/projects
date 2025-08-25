import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class mymessagescreen extends StatefulWidget {
  final DocumentSnapshot<Object?> usersnapshop;
  const mymessagescreen({super.key, required this.usersnapshop});

  @override
  State<mymessagescreen> createState() => _mymessagescreenState();
}

class _mymessagescreenState extends State<mymessagescreen> {
  final TextEditingController _msgcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(
        "------->>>> Sender ID   :: ${FirebaseAuth.instance.currentUser!.uid}");
    print("------->>>> Receiver ID :: ${widget.usersnapshop.id}");
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage("${widget.usersnapshop["profilePic"]}"),
            ),
            const SizedBox(width: 10),
            Text(
              widget.usersnapshop["username"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chat")
                  .where("receiver",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .where("sender", isEqualTo: widget.usersnapshop.id)
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, sendersnapshot) {
                if (sendersnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sendersnapshot.hasError) {
                  return Center(child: Text("Error: ${sendersnapshot.error}"));
                }
                var sendermessage = sendersnapshot.data?.docs ?? [];

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chat")
                      .where("sender",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where("receiver", isEqualTo: widget.usersnapshop.id)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, receiversnapshot) {
                    if (receiversnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (receiversnapshot.hasError) {
                      return Center(
                          child: Text("Error: ${receiversnapshot.error}"));
                    }

                    var receivermessage = receiversnapshot.data?.docs ?? [];
                    var allmessages = [...sendermessage, ...receivermessage];

                    if (allmessages.isEmpty) {
                      return const Center(child: Text("No messages yet."));
                    }

                    allmessages.sort(
                      (a, b) => (a["timestamp"] as Timestamp)
                          .compareTo(b["timestamp"] as Timestamp),
                    );

                    return ListView.builder(
                      itemCount: allmessages.length,
                      itemBuilder: (context, index) {
                        var message = allmessages[index];
                        String senderId = message["sender"];
                        bool currentUserIsSender =
                            senderId == FirebaseAuth.instance.currentUser!.uid;

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: currentUserIsSender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!currentUserIsSender)
                                CircleAvatar(
                                  child: Text(
                                    widget.usersnapshop["username"][0]
                                        .toString()
                                        .toUpperCase(),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: currentUserIsSender
                                        ? Colors.blueAccent
                                        : Colors.deepOrangeAccent,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message["message"],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        formatTimestamp(
                                            message["timestamp"] as Timestamp),
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _msgcontroller,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type message here...",
                      hintStyle: const TextStyle(color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.lightBlueAccent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String messagetext = _msgcontroller.text.trim();
                    if (messagetext.isNotEmpty) {
                      FirebaseFirestore.instance.collection("chat").add({
                        "sender": FirebaseAuth.instance.currentUser!.uid,
                        "receiver": widget.usersnapshop.id,
                        "message": messagetext,
                        "timestamp":DateTime.now(),
                      });
                      _msgcontroller.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
