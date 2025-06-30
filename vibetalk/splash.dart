import 'package:firebasedatabase/signup.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.network(
              "https://cdn.dribbble.com/users/1465636/screenshots/9174984/059_4x.png",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding:const EdgeInsets.all(12.0),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      backgroundImage: NetworkImage(
                        "https://images.pexels.com/photos/842991/pexels-photo-842991.jpeg?auto=compress&cs=tinysrgb&w=600",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      backgroundImage: NetworkImage(
                        "https://images.pexels.com/photos/3692887/pexels-photo-3692887.jpeg?auto=compress&cs=tinysrgb&w=600",
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      backgroundImage: NetworkImage(
                        "https://images.pexels.com/photos/3183155/pexels-photo-3183155.jpeg?auto=compress&cs=tinysrgb&w=600",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      backgroundImage: NetworkImage(
                        "https://images.pexels.com/photos/859265/pexels-photo-859265.jpeg?auto=compress&cs=tinysrgb&w=600",
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: const Color.fromARGB(161, 255, 255, 255),
                    ),
                    child: Column( 
                      
                      children: [
                        const SizedBox(height: 70),
                        const Text(
                          "Enjoy the new experience of\nchatting with global friends",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Connect with people around the world for free",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(112, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 55),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 50),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.green,
                            shadowColor: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MySignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Powered by",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Icon(Icons.logo_dev),
                            Text(
                              "Ussage",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
